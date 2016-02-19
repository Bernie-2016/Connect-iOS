import Quick
import Nimble
import UIKit

@testable import Connect

class NewsFeedControllerSpecs: QuickSpec {
    override func spec() {
        describe("NewsFeedController") {
            var subject: NewsFeedController!
            var newsFeedService: FakeNewsFeedService!
            let newsFeedItemControllerProvider = FakeNewsFeedItemControllerProvider()
            var newsFeedTableViewCellPresenter: FakeNewsFeedTableViewCellPresenter!
            var analyticsService: FakeAnalyticsService!
            var tabBarItemStylist: FakeTabBarItemStylist!
            var mainQueue: FakeOperationQueue!
            let theme = NewsFakeTheme()

            var navigationController: UINavigationController!

            beforeEach {
                newsFeedService = FakeNewsFeedService()
                newsFeedTableViewCellPresenter = FakeNewsFeedTableViewCellPresenter()
                tabBarItemStylist = FakeTabBarItemStylist()
                mainQueue = FakeOperationQueue()
                analyticsService = FakeAnalyticsService()

                subject = NewsFeedController(
                    newsFeedService: newsFeedService,
                    newsFeedItemControllerProvider: newsFeedItemControllerProvider,
                    newsFeedTableViewCellPresenter: newsFeedTableViewCellPresenter,
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    mainQueue: mainQueue,
                    theme: theme
                )

                navigationController = UINavigationController()
                navigationController.pushViewController(subject, animated: false)
                subject.view.layoutSubviews()
            }

            it("has the correct tab bar title") {
                expect(subject.title).to(equal("News"))
            }

            it("has the correct navigation item title") {
                expect(subject.navigationItem.title).to(equal("News"))
            }

            it("should set the back bar button item title correctly") {
                expect(subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "newsTabBarIconInactive")))
                expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "newsTabBarIcon")))
            }

            it("initially hides the table view, and shows the loading spinner") {
                expect(subject.tableView.hidden).to(equal(true));
                expect(subject.loadingIndicatorView.isAnimating()).to(equal(true))
            }

            it("has the page components as subviews") {
                let subViews = subject.view.subviews

                expect(subViews.contains(subject.tableView)).to(beTrue())
                expect(subViews.contains(subject.loadingIndicatorView)).to(beTrue())
            }

            it("styles the spinner with the theme") {
                expect(subject.loadingIndicatorView.color).to(equal(UIColor.greenColor()))
            }

            it("styles the table with the theme") {
                expect(subject.tableView.backgroundColor).to(equal(UIColor.blueColor()))
            }

            it("sets the spinner up to hide when stopped") {
                expect(subject.loadingIndicatorView.hidesWhenStopped).to(equal(true))
            }

            it("sets up the table view with the presenter") {
                expect(newsFeedTableViewCellPresenter.lastSetupTableView).to(beIdenticalTo(subject.tableView))
            }

            describe("when the controller appears") {
                beforeEach {
                    subject.viewWillAppear(false)
                }

                it("has an empty table") {
                    expect(subject.tableView.numberOfSections).to(equal(1))
                    expect(subject.tableView.numberOfRowsInSection(0)).to(equal(0))
                }

                it("asks the news repository for some news") {
                    expect(newsFeedService.fetchNewsFeedCalled).to(beTrue())
                }

                describe("when the news repository returns some news items", {
                    let newsArticleA = TestUtils.newsArticle()
                    let newsArticleB = TestUtils.newsArticle()

                    let newsArticles: [NewsFeedItem] = [newsArticleA, newsArticleB]

                    it("has 1 section") {
                        newsFeedService.lastReturnedPromise.resolve(newsArticles)

                        expect(subject.tableView.numberOfSections).to(equal(1))
                    }

                    it("shows the table view, and stops the loading spinner") {
                        newsFeedService.lastReturnedPromise.resolve(newsArticles)

                        expect(subject.tableView.hidden).to(equal(false));
                        expect(subject.loadingIndicatorView.isAnimating()).to(equal(false))
                    }

                    describe("the content of the news feed") {
                        beforeEach {
                            newsFeedService.lastReturnedPromise.resolve(newsArticles)
                        }

                        it("shows the news items in the table, using the presenter") {
                            expect(subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                            let indexPathA = NSIndexPath(forRow: 0, inSection: 0)
                            let cellA = subject.tableView.cellForRowAtIndexPath(indexPathA) as! NewsArticleTableViewCell
                            expect(cellA).to(beIdenticalTo(newsFeedTableViewCellPresenter.returnedCells[0]))
                            expect(newsFeedTableViewCellPresenter.receivedTableViews[0]).to(beIdenticalTo(subject.tableView))
                            expect(newsFeedTableViewCellPresenter.receivedNewsFeedItems[0] as? NewsArticle).to(beIdenticalTo(newsArticleA))
                            expect(newsFeedTableViewCellPresenter.receivedIndexPaths[0]).to(equal(indexPathA))

                            let indexPathB = NSIndexPath(forRow: 1, inSection: 0)
                            let cellB = subject.tableView.cellForRowAtIndexPath(indexPathB) as! NewsArticleTableViewCell
                            expect(cellB).to(beIdenticalTo(newsFeedTableViewCellPresenter.returnedCells[1]))
                            expect(newsFeedTableViewCellPresenter.receivedTableViews[1]).to(beIdenticalTo(subject.tableView))
                            expect(newsFeedTableViewCellPresenter.receivedNewsFeedItems[1] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                            expect(newsFeedTableViewCellPresenter.receivedIndexPaths[1]).to(equal(indexPathB))
                        }
                    }
                })

                context("when the repository encounters an error fetching items") {
                    let expectedUnderlyingError = NSError(domain: "boo", code: 0, userInfo: nil)
                    let expectedError = NewsFeedServiceError.FailedToFetchNews(underlyingErrors: [expectedUnderlyingError])

                    beforeEach {
                        newsFeedService.lastReturnedPromise.reject(expectedError)
                    }

                    it("logs that error to the analytics service") {
                        switch(analyticsService.lastError  as! NewsFeedServiceError) {
                        case .FailedToFetchNews(let underlyingErrors):
                            expect(underlyingErrors.count).to(equal(1))
                            let error = underlyingErrors.first as! NSError

                            expect(error).to(beIdenticalTo(expectedUnderlyingError))
                        }
                        expect(analyticsService.lastErrorContext).to(equal("Failed to load news feed"))
                    }

                    it("shows the an error in the table") {
                        let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                        expect(subject.tableView.numberOfSections).to(equal(1))
                        expect(subject.tableView.numberOfRowsInSection(0)).to(equal(1))

                        expect(cell.textLabel!.text).to(equal("Oops! Sorry, we couldn't load any news."))
                    }

                    it("styles the items in the table using the theme") {
                        let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                        expect(cell.textLabel!.textColor).to(equal(UIColor.magentaColor()))
                        expect(cell.textLabel!.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    }

                    context("and then the user refreshes the news feed") {
                        beforeEach {
                            subject.viewWillAppear(false)
                        }

                        describe("when the news repository returns some news items") {
                            let newsArticleA = TestUtils.newsArticle()
                            let newsArticleB = TestUtils.newsArticle()

                            let newsArticles: [NewsFeedItem] = [newsArticleA, newsArticleB]

                            it("has 1 section") {
                                newsFeedService.lastReturnedPromise.resolve(newsArticles)

                                expect(subject.tableView.numberOfSections).to(equal(1))
                            }


                            it("shows the news items in the table") {
                                newsFeedService.lastReturnedPromise.resolve(newsArticles)

                                expect(subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                                let cellA = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsArticleTableViewCell
                                expect(cellA).to(beIdenticalTo(newsFeedTableViewCellPresenter.returnedCells[0]))
                                expect(newsFeedTableViewCellPresenter.receivedTableViews[0]).to(beIdenticalTo(subject.tableView))
                                expect(newsFeedTableViewCellPresenter.receivedNewsFeedItems[0] as? NewsArticle).to(beIdenticalTo(newsArticleA))


                                let cellB = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! NewsArticleTableViewCell
                                expect(cellB).to(beIdenticalTo(newsFeedTableViewCellPresenter.returnedCells[1]))
                                expect(newsFeedTableViewCellPresenter.receivedTableViews[1]).to(beIdenticalTo(subject.tableView))
                                expect(newsFeedTableViewCellPresenter.receivedNewsFeedItems[1] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                            }
                        }
                    }
                }
            }

           describe("pull to refresh") {
                it("asks the news feed service to reload the news feed") {
                    newsFeedService.fetchNewsFeedCalled = false
                    subject.refreshControl.sendActionsForControlEvents(.ValueChanged)
                    expect(newsFeedService.fetchNewsFeedCalled).to(beTrue())
                }

                describe("when the news feed service successfully resolves its promise with news feed items") {
                    beforeEach {
                        subject.refreshControl.sendActionsForControlEvents(.ValueChanged)
                    }

                    it("stops the pull to refresh spinner") {
                        newsFeedService.lastReturnedPromise.resolve([])

                        expect(subject.refreshControl.refreshing).to(beTrue())

                        mainQueue.lastReceivedBlock()

                        expect(subject.refreshControl.refreshing).to(beFalse())
                    }
                }

                describe("when the news feed service rejects its promise with an error") {
                    beforeEach {
                        subject.refreshControl.sendActionsForControlEvents(.ValueChanged)
                    }

                    it("stops the pull to refresh spinner") {
                        let error = NewsFeedServiceError.FailedToFetchNews(underlyingErrors: [NSError(domain: "", code: 0, userInfo: nil)])
                        newsFeedService.lastReturnedPromise.reject(error)

                        expect(subject.refreshControl.refreshing).to(beTrue())

                        mainQueue.lastReceivedBlock()

                        expect(subject.refreshControl.refreshing).to(beFalse())
                    }
                }
            }

            describe("Tapping on a news item") {
                let expectedNewsItemA = TestUtils.newsArticle()
                let expectedNewsItemB = NewsArticle(title: "B", date: NSDate(), body: "B Body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL(string: "http://example.com/b")!)

                beforeEach {
                    subject.viewWillAppear(false)

                    let newsArticles: [NewsFeedItem] = [expectedNewsItemA, expectedNewsItemB]

                    newsFeedService.lastReturnedPromise.resolve(newsArticles)

                    let tableView = subject.tableView
                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
                }

                afterEach {
                    navigationController.popViewControllerAnimated(false)
                }


                it("should push a correctly configured news item view controller onto the nav stack") {
                    expect(newsFeedItemControllerProvider.lastNewsFeedItem as? NewsArticle).to(beIdenticalTo(expectedNewsItemB))
                    expect(subject.navigationController!.topViewController).to(beIdenticalTo(newsFeedItemControllerProvider.controller))
                }

                it("tracks the content view with the analytics service") {
                    expect(analyticsService.lastContentViewName).to(equal(expectedNewsItemB.title))
                    expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.NewsArticle))
                    expect(analyticsService.lastContentViewID).to(equal(expectedNewsItemB.identifier))
                }
            }
        }
    }
}

private class NewsFakeTheme: FakeTheme {
    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func newsFeedBackgroundColor() -> UIColor {
        return UIColor.blueColor()
    }

    override func defaultSpinnerColor() -> UIColor {
        return UIColor.greenColor()
    }
}

private class FakeNewsFeedService: NewsFeedService {
    var lastReturnedPromise: NewsFeedPromise!
    var fetchNewsFeedCalled: Bool = false

    func fetchNewsFeed() -> NewsFeedFuture {
        fetchNewsFeedCalled = true
        lastReturnedPromise = NewsFeedPromise()
        return lastReturnedPromise.future
    }
}
