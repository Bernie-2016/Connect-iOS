import Quick
import Nimble
import UIKit

@testable import Movement

private class NewsFakeTheme : FakeTheme {
    override func newsFeedBackgroundColor() -> UIColor {
        return UIColor.blueColor()
    }

    override func defaultSpinnerColor() -> UIColor {
        return UIColor.greenColor()
    }
}

private class FakeNewsArticleRepository : Movement.NewsArticleRepository {
    var lastCompletionBlock: ((Array<NewsArticle>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchNewsCalled: Bool = false

    func fetchNewsArticles(completion: (Array<NewsArticle>) -> Void, error: (NSError) -> Void) {
        self.fetchNewsCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class FakeNewsArticleControllerProvider : Movement.NewsArticleControllerProvider {
    let controller = NewsArticleController(newsArticle: NewsArticle(title: "a", date: NSDate(), body: "a body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL()),
        imageRepository: FakeImageRepository(),
        timeIntervalFormatter: FakeTimeIntervalFormatter(),
        analyticsService: FakeAnalyticsService(),
        urlOpener: FakeURLOpener(),
        urlAttributionPresenter: FakeURLAttributionPresenter(),
        theme: FakeTheme())
    var lastNewsArticle: NewsArticle?

    func provideInstanceWithNewsArticle(newsArticle: NewsArticle) -> NewsArticleController {
        self.lastNewsArticle = newsArticle;
        return self.controller
    }
}

class NewsFeedControllerSpecs: QuickSpec {
    var subject: NewsFeedController!
    private let newsArticleRepository: FakeNewsArticleRepository! =  FakeNewsArticleRepository()
    let newsArticleControllerProvider = FakeNewsArticleControllerProvider()
    private var newsFeedTableViewCellPresenter: FakeNewsFeedTableViewCellPresenter!
    var analyticsService: FakeAnalyticsService!
    var tabBarItemStylist: FakeTabBarItemStylist!
    let theme: Theme! = NewsFakeTheme()

    var navigationController: UINavigationController!

    override func spec() {
        describe("NewsFeedController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()
                self.newsFeedTableViewCellPresenter = FakeNewsFeedTableViewCellPresenter()

                self.tabBarItemStylist = FakeTabBarItemStylist()
                let theme = NewsFakeTheme()

                self.subject = NewsFeedController(
                    newsArticleRepository: self.newsArticleRepository,
                    newsArticleControllerProvider: self.newsArticleControllerProvider,
                    newsFeedTableViewCellPresenter: self.newsFeedTableViewCellPresenter,
                    analyticsService: self.analyticsService,
                    tabBarItemStylist: self.tabBarItemStylist,
                    theme: theme
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

            describe("when the controller appears") {
                beforeEach {
                    self.subject.viewWillAppear(false)
                }

                it("has an empty table") {
                    expect(self.subject.tableView.numberOfSections).to(equal(1))
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(0))
                }

                it("asks the news repository for some news") {
                    expect(self.newsArticleRepository.fetchNewsCalled).to(beTrue())
                }

                describe("when the news repository returns some news items", {
                    let newsArticleADate = NSDate(timeIntervalSince1970: 0)
                    let newsArticleBDate = NSDate(timeIntervalSince1970: 86401)
                    let newsArticleA = NewsArticle(title: "Bernie to release new album", date: newsArticleADate, body: "yeahhh", excerpt: "excerpt A", imageURL: NSURL(string: "http://bs.com")!, url: NSURL())
                    let newsArticleB = NewsArticle(title: "Bernie up in the polls!", date: newsArticleBDate, body: "body text", excerpt: "excerpt B", imageURL: nil, url: NSURL())

                    let newsArticles = [newsArticleA, newsArticleB]

                    it("has 1 section") {
                        self.newsArticleRepository.lastCompletionBlock!(newsArticles)

                        expect(self.subject.tableView.numberOfSections).to(equal(1))
                    }

                    it("shows the table view, and stops the loading spinner") {
                        self.newsArticleRepository.lastCompletionBlock!(newsArticles)

                        expect(self.subject.tableView.hidden).to(equal(false));
                        expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(false))
                    }

                    describe("the content of the news feed") {
                        beforeEach {
                            self.newsArticleRepository.lastCompletionBlock!(newsArticles)
                        }

                        it("shows the news items in the table, using the presenter") {
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
                })

                context("when the repository encounters an error fetching items") {
                    let expectedError = NSError(domain: "some error", code: 666, userInfo: nil)

                    beforeEach {
                        self.newsArticleRepository.lastErrorBlock!(expectedError)
                    }

                    it("logs that error to the analytics service") {
                        expect(self.analyticsService.lastError).to(beIdenticalTo(expectedError))
                        expect(self.analyticsService.lastErrorContext).to(equal("Failed to load news feed"))
                    }

                    it("shows the an error in the table using the presenter") {
                        expect(self.subject.tableView.numberOfSections).to(equal(1))
                        expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(1))

                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                        expect(cell).to(beIdenticalTo(self.newsFeedTableViewCellPresenter.returnedErrorCell))
                        expect(self.newsFeedTableViewCellPresenter.lastReceivedErrorTableView).to(beIdenticalTo(self.subject.tableView))
                    }

                    context("and then the user refreshes the news feed") {
                        beforeEach {
                            self.subject.viewWillAppear(false)
                        }

                        describe("when the news repository returns some news items") {
                            let newsArticleADate = NSDate(timeIntervalSince1970: 0)
                            let newsArticleBDate = NSDate(timeIntervalSince1970: 86401)
                            let newsArticleA = NewsArticle(title: "Bernie to release new album", date: newsArticleADate, body: "yeahhh", excerpt: "excerpt", imageURL: NSURL(string: "http://bs.com")!, url: NSURL())
                            let newsArticleB = NewsArticle(title: "Bernie up in the polls!", date: newsArticleBDate, body: "body text", excerpt: "excerpt", imageURL: NSURL(), url: NSURL())

                            let newsArticles = [newsArticleA, newsArticleB]

                            it("has 1 section") {
                                self.newsArticleRepository.lastCompletionBlock!(newsArticles)

                                expect(self.subject.tableView.numberOfSections).to(equal(1))
                            }


                            it("shows the news items in the table") {
                                self.newsArticleRepository.lastCompletionBlock!(newsArticles)

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
                let expectedNewsArticleA = NewsArticle(title: "A", date: NSDate(), body: "A Body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL(string: "http://example.com/a")!)
                let expectedNewsArticleB = NewsArticle(title: "B", date: NSDate(), body: "B Body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL(string: "http://example.com/b")!)
                beforeEach {
                    self.subject.viewWillAppear(false)

                    let newsArticles = [expectedNewsArticleA, expectedNewsArticleB]

                    self.newsArticleRepository.lastCompletionBlock!(newsArticles)

                    let tableView = self.subject.tableView
                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
                }

                afterEach {
                    self.navigationController.popViewControllerAnimated(false)
                }


                it("should push a correctly configured news item view controller onto the nav stack") {
                    expect(self.newsArticleControllerProvider.lastNewsArticle).to(beIdenticalTo(expectedNewsArticleB))
                    expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.newsArticleControllerProvider.controller))
                }

                it("tracks the content view with the analytics service") {
                    expect(self.analyticsService.lastContentViewName).to(equal(expectedNewsArticleB.title))
                    expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.NewsArticle))
                    expect(self.analyticsService.lastContentViewID).to(equal(expectedNewsArticleB.url.absoluteString))
                }
            }
        }
    }
}

