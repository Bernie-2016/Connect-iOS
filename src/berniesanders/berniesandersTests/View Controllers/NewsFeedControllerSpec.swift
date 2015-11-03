import Quick
import Nimble
import UIKit

@testable import berniesanders

class NewsFakeTheme : FakeTheme {
    override func newsFeedBackgroundColor() -> UIColor {
        return UIColor.blueColor()
    }

    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func newsFeedExcerptFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(21)
    }

    override func newsFeedExcerptColor() -> UIColor {
        return UIColor.redColor()
    }

    override func newsFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)    }

    override func newsFeedDefaultDisclosureColor() -> UIColor {
        return UIColor.brownColor()
    }

    override func newsFeedBreakingDisclosureColor() -> UIColor {
        return UIColor.whiteColor()
    }

    override func newsFeedHeadlineTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(666)
    }

    override func newsfeedHeadlineTitleColor() -> UIColor {
        return UIColor.yellowColor()
    }

    override func newsFeedHeadlineTitleBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }

    override func defaultSpinnerColor() -> UIColor {
        return UIColor.greenColor()
    }
}

class FakeNewsItemRepository : berniesanders.NewsItemRepository {
    var lastCompletionBlock: ((Array<NewsItem>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchNewsCalled: Bool = false

    func fetchNewsItems(completion: (Array<NewsItem>) -> Void, error: (NSError) -> Void) {
        self.fetchNewsCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class FakeNewsItemControllerProvider : berniesanders.NewsItemControllerProvider {
    let controller = NewsItemController(newsItem: NewsItem(title: "a", date: NSDate(), body: "a body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL()),
        imageRepository: FakeImageRepository(),
        timeIntervalFormatter: FakeTimeIntervalFormatter(),
        analyticsService: FakeAnalyticsService(),
        urlOpener: FakeURLOpener(),
        urlAttributionPresenter: FakeURLAttributionPresenter(),
        theme: FakeTheme())
    var lastNewsItem: NewsItem?

    func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController {
        self.lastNewsItem = newsItem;
        return self.controller
    }
}

class NewsFeedControllerSpecs: QuickSpec {
    var subject: NewsFeedController!
    let newsItemRepository: FakeNewsItemRepository! =  FakeNewsItemRepository()
    var imageRepository: FakeImageRepository!
    var timeIntervalFormatter: FakeTimeIntervalFormatter!
    let newsItemControllerProvider = FakeNewsItemControllerProvider()
    var analyticsService: FakeAnalyticsService!
    var tabBarItemStylist: FakeTabBarItemStylist!
    let theme: Theme! = NewsFakeTheme()

    var navigationController: UINavigationController!

    override func spec() {
        describe("NewsFeedController") {
            beforeEach {
                self.imageRepository = FakeImageRepository()
                self.timeIntervalFormatter = FakeTimeIntervalFormatter()
                self.analyticsService = FakeAnalyticsService()
                self.tabBarItemStylist = FakeTabBarItemStylist()
                let theme = NewsFakeTheme()

                self.subject = NewsFeedController(
                    newsItemRepository: self.newsItemRepository,
                    imageRepository: self.imageRepository,
                    timeIntervalFormatter: self.timeIntervalFormatter,
                    newsItemControllerProvider: self.newsItemControllerProvider,
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
                    expect(self.newsItemRepository.fetchNewsCalled).to(beTrue())
                }

                describe("when the news repository returns some news items", {
                    let newsItemADate = NSDate(timeIntervalSince1970: 0)
                    let newsItemBDate = NSDate(timeIntervalSince1970: 86401)
                    let newsItemA = NewsItem(title: "Bernie to release new album", date: newsItemADate, body: "yeahhh", excerpt: "excerpt A", imageURL: NSURL(string: "http://bs.com")!, url: NSURL())
                    let newsItemB = NewsItem(title: "Bernie up in the polls!", date: newsItemBDate, body: "body text", excerpt: "excerpt B", imageURL: nil, url: NSURL())

                    let newsItems = [newsItemA, newsItemB]

                    it("has 1 section") {
                        self.newsItemRepository.lastCompletionBlock!(newsItems)

                        expect(self.subject.tableView.numberOfSections).to(equal(1))
                    }

                    it("shows the table view, and stops the loading spinner") {
                        self.newsItemRepository.lastCompletionBlock!(newsItems)

                        expect(self.subject.tableView.hidden).to(equal(false));
                        expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(false))
                    }

                    describe("the content of the news feed") {
                        beforeEach {
                            self.newsItemRepository.lastCompletionBlock!(newsItems)
                        }

                        it("shows the news items in the table, using the time interval formatter") {
                            expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                            let cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell
                            expect(cellA.titleLabel.text).to(equal("Bernie to release new album"))
                            expect(cellA.excerptLabel.text).to(equal("excerpt A"))
                            expect(cellA.dateLabel.text).to(equal("abbreviated 1970-01-01 00:00:00 +0000"))

                            let cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! NewsItemTableViewCell
                            expect(cellB.titleLabel.text).to(equal("Bernie up in the polls!"))
                            expect(cellB.excerptLabel.text).to(equal("excerpt B"))
                            expect(cellB.dateLabel.text).to(equal("abbreviated 1970-01-02 00:00:01 +0000"))

                            expect(self.timeIntervalFormatter.lastAbbreviatedDates).to(equal([newsItemADate, newsItemBDate]))
                        }

                        it("initially nils out the image") {
                            var cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))  as! NewsItemTableViewCell
                            cell.newsImageView.image = TestUtils.testImageNamed("bernie", type: "jpg")
                            cell = self.subject.tableView.dataSource?.tableView(self.subject.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))  as! NewsItemTableViewCell
                            expect(cell.newsImageView.image).to(beNil())
                        }

                        context("when the news item has an image URL") {
                            it("asks the image repository to fetch the image") {
                                self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))

                                expect(self.imageRepository.lastReceivedURL).to(beIdenticalTo(newsItemA.imageURL))
                            }

                            it("shows the image view") {
                                var cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell
                                cell.newsImageVisible = false
                                cell = self.subject.tableView.dataSource?.tableView(self.subject.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell

                                expect(cell.newsImageVisible).to(beTrue())
                            }

                            context("when the image is loaded succesfully") {
                                it("sets the image") {
                                    let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    self.imageRepository.lastRequestDeferred.resolveWithValue(bernieImage)
                                    expect(cell.newsImageView.image).to(beIdenticalTo(bernieImage))
                                }
                            }
                        }

                        context("when the news item does not have an image URL") {
                            it("does not make a call to the image repository") {
                                self.imageRepository.lastReceivedURL = nil
                                self.subject.tableView.dataSource?.tableView(self.subject.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                                expect(self.imageRepository.lastReceivedURL).to(beNil())
                            }

                            it("hides the image view") {
                                let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! NewsItemTableViewCell
                                expect(cell.newsImageVisible).to(beFalse())
                            }
                        }

                        it("styles the items in the table") {
                            let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell

                            expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                            expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                            expect(cell.excerptLabel.textColor).to(equal(UIColor.redColor()))
                            expect(cell.excerptLabel.font).to(equal(UIFont.boldSystemFontOfSize(21)))
                            expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                        }

                        context("when the news item is from today") {
                            beforeEach {
                                self.timeIntervalFormatter.returnsDaysSinceDate = 0
                            }

                            it("uses the breaking styling for the date label") {
                                let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell

                                expect(cell.dateLabel.textColor).to(equal(UIColor.whiteColor()))
                            }

                            it("uses the breaking styling for the disclosure indicator") {
                                let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell

                                expect(cell.disclosureView.color).to(equal(UIColor.whiteColor()))
                            }

                        }

                        context("when the news item is from the past") {
                            beforeEach {
                                self.timeIntervalFormatter.returnsDaysSinceDate = 1
                            }

                            it("uses the standard styling for the date label") {
                                let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell

                                expect(cell.dateLabel.textColor).to(equal(UIColor.brownColor()))
                            }

                            it("uses the standard styling for the disclosure indicator") {
                                let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell

                                expect(cell.disclosureView.color).to(equal(UIColor.brownColor()))
                            }
                        }
                    }
                })

                context("when the repository encounters an error fetching items") {
                    let expectedError = NSError(domain: "some error", code: 666, userInfo: nil)

                    beforeEach {
                        self.newsItemRepository.lastErrorBlock!(expectedError)
                    }

                    it("logs that error to the analytics service") {
                        expect(self.analyticsService.lastError).to(beIdenticalTo(expectedError))
                        expect(self.analyticsService.lastErrorContext).to(equal("Failed to load news feed"))
                    }

                    it("shows the an error in the table") {
                        expect(self.subject.tableView.numberOfSections).to(equal(1))
                        expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(1))

                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                        expect(cell.textLabel!.text).to(equal("Oops! Sorry, we couldn't load any news."))
                    }

                    it("styles the items in the table") {
                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                        expect(cell.textLabel!.textColor).to(equal(UIColor.magentaColor()))
                        expect(cell.textLabel!.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    }

                    context("and then the user refreshes the news feed") {
                        beforeEach {
                            self.subject.viewWillAppear(false)
                        }

                        describe("when the news repository returns some news items") {
                            let newsItemADate = NSDate(timeIntervalSince1970: 0)
                            let newsItemBDate = NSDate(timeIntervalSince1970: 86401)
                            let newsItemA = NewsItem(title: "Bernie to release new album", date: newsItemADate, body: "yeahhh", excerpt: "excerpt", imageURL: NSURL(string: "http://bs.com")!, url: NSURL())
                            let newsItemB = NewsItem(title: "Bernie up in the polls!", date: newsItemBDate, body: "body text", excerpt: "excerpt", imageURL: NSURL(), url: NSURL())

                            let newsItems = [newsItemA, newsItemB]

                            it("has 1 section") {
                                self.newsItemRepository.lastCompletionBlock!(newsItems)

                                expect(self.subject.tableView.numberOfSections).to(equal(1))
                            }


                            it("shows the news items in the table") {
                                self.newsItemRepository.lastCompletionBlock!(newsItems)

                                expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                                let cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsItemTableViewCell
                                expect(cellA.titleLabel.text).to(equal("Bernie to release new album"))
                                expect(cellA.dateLabel.text).to(equal("abbreviated 1970-01-01 00:00:00 +0000"))


                                let cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! NewsItemTableViewCell
                                expect(cellB.titleLabel.text).to(equal("Bernie up in the polls!"))
                                expect(cellB.dateLabel.text).to(equal("abbreviated 1970-01-02 00:00:01 +0000"))
                            }
                        }
                    }
                }
            }

            describe("Tapping on a news item") {
                let expectedNewsItemA = NewsItem(title: "A", date: NSDate(), body: "A Body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL(string: "http://example.com/a")!)
                let expectedNewsItemB = NewsItem(title: "B", date: NSDate(), body: "B Body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL(string: "http://example.com/b")!)
                beforeEach {
                    self.subject.viewWillAppear(false)

                    let newsItems = [expectedNewsItemA, expectedNewsItemB]

                    self.newsItemRepository.lastCompletionBlock!(newsItems)

                    let tableView = self.subject.tableView
                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
                }

                afterEach {
                    self.navigationController.popViewControllerAnimated(false)
                }


                it("should push a correctly configured news item view controller onto the nav stack") {
                    expect(self.newsItemControllerProvider.lastNewsItem).to(beIdenticalTo(expectedNewsItemB))
                    expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.newsItemControllerProvider.controller))
                }

                it("tracks the content view with the analytics service") {
                    expect(self.analyticsService.lastContentViewName).to(equal(expectedNewsItemB.title))
                    expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.NewsItem))
                    expect(self.analyticsService.lastContentViewID).to(equal(expectedNewsItemB.url.absoluteString))
                }
            }
        }
    }
}

