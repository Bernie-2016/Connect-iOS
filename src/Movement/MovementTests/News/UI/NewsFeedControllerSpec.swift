import Quick
import Nimble
import UIKit

@testable import Movement

class NewsFeedControllerSpecs: QuickSpec {
    var subject: NewsFeedController!
    private var newsFeedService: FakeNewsFeedService!
    let newsFeedItemControllerProvider = FakeNewsFeedItemControllerProvider()
    private var newsFeedTableViewCellPresenter: FakeNewsFeedTableViewCellPresenter!
    var analyticsService: FakeAnalyticsService!
    var tabBarItemStylist: FakeTabBarItemStylist!
    private let theme = NewsFakeTheme()

    var navigationController: UINavigationController!

    override func spec() {
        describe("NewsFeedController") {
            beforeEach {
                self.newsFeedService = FakeNewsFeedService()
                self.newsFeedTableViewCellPresenter = FakeNewsFeedTableViewCellPresenter()

                self.tabBarItemStylist = FakeTabBarItemStylist()
                self.analyticsService = FakeAnalyticsService()

                self.subject = NewsFeedController(
                    newsFeedService: self.newsFeedService,
                    newsFeedItemControllerProvider: self.newsFeedItemControllerProvider,
                    newsFeedTableViewCellPresenter: self.newsFeedTableViewCellPresenter,
                    analyticsService: self.analyticsService,
                    tabBarItemStylist: self.tabBarItemStylist,
                    theme: self.theme
                )

                self.navigationController = UINavigationController()
                self.navigationController.pushViewController(self.subject, animated: false)
                self.subject.view.layoutSubviews()
            }

            it("has the correct tab bar title") {
                expect(self.subject.title).to(equal("News"))
            }

            it("has the correct navigation item title") {
                expect(self.subject.navigationItem.title).to(equal("News"))
            }

            it("should set the back bar button item title correctly") {
                expect(self.subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(self.tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(self.subject.tabBarItem))

                expect(self.tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "newsTabBarIconInactive")))
                expect(self.tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "newsTabBarIcon")))
            }

            it("initially hides the table view, and shows the loading spinner") {
                expect(self.subject.tableView.hidden).to(equal(true));
                expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(true))
            }

            it("has the page components as subviews") {
                let subViews = self.subject.view.subviews

                expect(subViews.contains(self.subject.tableView)).to(beTrue())
                expect(subViews.contains(self.subject.loadingIndicatorView)).to(beTrue())
            }

            it("styles the spinner with the theme") {
                expect(self.subject.loadingIndicatorView.color).to(equal(UIColor.greenColor()))
            }

            it("styles the table with the theme") {
                expect(self.subject.tableView.backgroundColor).to(equal(UIColor.blueColor()))
            }

            it("sets the spinner up to hide when stopped") {
                expect(self.subject.loadingIndicatorView.hidesWhenStopped).to(equal(true))
            }

            it("sets up the table view with the presenter") {
                expect(self.newsFeedTableViewCellPresenter.lastSetupTableView).to(beIdenticalTo(self.subject.tableView))
            }

            describe("when the controller appears") {
                beforeEach {
                    self.subject.viewWillAppear(false)
                }

                it("has an empty table") {
                    expect(self.subject.tableView.numberOfSections).to(equal(1))
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(0))
                }

                it("asks the news repository for some news") {
                    expect(self.newsFeedService.fetchNewsFeedCalled).to(beTrue())
                }

                describe("when the news repository returns some news items", {
                    let newsArticleA = TestUtils.newsArticle()
                    let newsArticleB = TestUtils.newsArticle()

                    let newsArticles: [NewsFeedItem] = [newsArticleA, newsArticleB]

                    it("has 1 section") {
                        self.newsFeedService.lastCompletionBlock!(newsArticles)

                        expect(self.subject.tableView.numberOfSections).to(equal(1))
                    }

                    it("shows the table view, and stops the loading spinner") {
                        self.newsFeedService.lastCompletionBlock!(newsArticles)

                        expect(self.subject.tableView.hidden).to(equal(false));
                        expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(false))
                    }

                    describe("the content of the news feed") {
                        beforeEach {
                            self.newsFeedService.lastCompletionBlock!(newsArticles)
                        }

                        it("shows the news items in the table, using the presenter") {
                            expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                            let indexPathA = NSIndexPath(forRow: 0, inSection: 0)
                            let cellA = self.subject.tableView.cellForRowAtIndexPath(indexPathA) as! NewsArticleTableViewCell
                            expect(cellA).to(beIdenticalTo(self.newsFeedTableViewCellPresenter.returnedCells[0]))
                            expect(self.newsFeedTableViewCellPresenter.receivedTableViews[0]).to(beIdenticalTo(self.subject.tableView))
                            expect(self.newsFeedTableViewCellPresenter.receivedNewsFeedItems[0] as? NewsArticle).to(beIdenticalTo(newsArticleA))
                            expect(self.newsFeedTableViewCellPresenter.receivedIndexPaths[0]).to(equal(indexPathA))

                            let indexPathB = NSIndexPath(forRow: 1, inSection: 0)
                            let cellB = self.subject.tableView.cellForRowAtIndexPath(indexPathB) as! NewsArticleTableViewCell
                            expect(cellB).to(beIdenticalTo(self.newsFeedTableViewCellPresenter.returnedCells[1]))
                            expect(self.newsFeedTableViewCellPresenter.receivedTableViews[1]).to(beIdenticalTo(self.subject.tableView))
                            expect(self.newsFeedTableViewCellPresenter.receivedNewsFeedItems[1] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                            expect(self.newsFeedTableViewCellPresenter.receivedIndexPaths[1]).to(equal(indexPathB))
                        }
                    }
                })

                context("when the repository encounters an error fetching items") {
                    let expectedError = NSError(domain: "some error", code: 666, userInfo: nil)

                    beforeEach {
                        self.newsFeedService.lastErrorBlock!(expectedError)
                    }

                    it("logs that error to the analytics service") {
                        expect(self.analyticsService.lastError as NSError).to(beIdenticalTo(expectedError))
                        expect(self.analyticsService.lastErrorContext).to(equal("Failed to load news feed"))
                    }

                    it("shows the an error in the table") {
                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                        expect(self.subject.tableView.numberOfSections).to(equal(1))
                        expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(1))

                        expect(cell.textLabel!.text).to(equal("Oops! Sorry, we couldn't load any news."))
                    }

                    it("styles the items in the table using the theme") {
                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                        expect(cell.textLabel!.textColor).to(equal(UIColor.magentaColor()))
                        expect(cell.textLabel!.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    }

                    context("and then the user refreshes the news feed") {
                        beforeEach {
                            self.subject.viewWillAppear(false)
                        }

                        describe("when the news repository returns some news items") {
                            let newsArticleA = TestUtils.newsArticle()
                            let newsArticleB = TestUtils.newsArticle()

                            let newsArticles: [NewsFeedItem] = [newsArticleA, newsArticleB]

                            it("has 1 section") {
                                self.newsFeedService.lastCompletionBlock!(newsArticles)

                                expect(self.subject.tableView.numberOfSections).to(equal(1))
                            }


                            it("shows the news items in the table") {
                                self.newsFeedService.lastCompletionBlock!(newsArticles)

                                expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                                let cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsArticleTableViewCell
                                expect(cellA).to(beIdenticalTo(self.newsFeedTableViewCellPresenter.returnedCells[0]))
                                expect(self.newsFeedTableViewCellPresenter.receivedTableViews[0]).to(beIdenticalTo(self.subject.tableView))
                                expect(self.newsFeedTableViewCellPresenter.receivedNewsFeedItems[0] as? NewsArticle).to(beIdenticalTo(newsArticleA))


                                let cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! NewsArticleTableViewCell
                                expect(cellB).to(beIdenticalTo(self.newsFeedTableViewCellPresenter.returnedCells[1]))
                                expect(self.newsFeedTableViewCellPresenter.receivedTableViews[1]).to(beIdenticalTo(self.subject.tableView))
                                expect(self.newsFeedTableViewCellPresenter.receivedNewsFeedItems[1] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                            }
                        }
                    }
                }
            }

            describe("Tapping on a news item") {
                let expectedNewsItemA = TestUtils.newsArticle()
                let expectedNewsItemB = NewsArticle(title: "B", date: NSDate(), body: "B Body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL(string: "http://example.com/b")!)

                beforeEach {
                    self.subject.viewWillAppear(false)

                    let newsArticles: [NewsFeedItem] = [expectedNewsItemA, expectedNewsItemB]

                    self.newsFeedService.lastCompletionBlock!(newsArticles)

                    let tableView = self.subject.tableView
                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
                }

                afterEach {
                    self.navigationController.popViewControllerAnimated(false)
                }


                it("should push a correctly configured news item view controller onto the nav stack") {
                    expect(self.newsFeedItemControllerProvider.lastNewsFeedItem as? NewsArticle).to(beIdenticalTo(expectedNewsItemB))
                    expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.newsFeedItemControllerProvider.controller))
                }

                it("tracks the content view with the analytics service") {
                    expect(self.analyticsService.lastContentViewName).to(equal(expectedNewsItemB.title))
                    expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.NewsArticle))
                    expect(self.analyticsService.lastContentViewID).to(equal(expectedNewsItemB.identifier))
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
    var lastCompletionBlock: (([NewsFeedItem]) -> Void)?
    var lastErrorBlock: ((ErrorType) -> Void)?
    var fetchNewsFeedCalled: Bool = false

    func fetchNewsFeed(completion: ([NewsFeedItem]) -> Void, error: (ErrorType) -> Void) {
        self.fetchNewsFeedCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}
