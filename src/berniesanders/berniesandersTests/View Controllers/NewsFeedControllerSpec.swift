import Quick
import Nimble
import UIKit

@testable import berniesanders

class NewsFakeTheme : FakeTheme {
    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func newsFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)    }

    override func newsFeedDateColor() -> UIColor {
        return UIColor.brownColor()
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
    let controller = NewsItemController(newsItem: NewsItem(title: "a", date: NSDate(), body: "a body", imageURL: NSURL(), URL: NSURL()),
        imageRepository: FakeImageRepository(),
        dateFormatter: NSDateFormatter(),
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
    var imageRepository : FakeImageRepository!
    let newsItemControllerProvider = FakeNewsItemControllerProvider()
    let settingsController = TestUtils.settingsController()
    var analyticsService: FakeAnalyticsService!
    var tabBarItemStylist: FakeTabBarItemStylist!
    let theme: Theme! = NewsFakeTheme()

    var navigationController: UINavigationController!

    override func spec() {
        describe("NewsFeedController") {
            beforeEach {
                self.imageRepository = FakeImageRepository()
                self.analyticsService = FakeAnalyticsService()
                self.tabBarItemStylist = FakeTabBarItemStylist()
                let theme = NewsFakeTheme()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                dateFormatter.timeZone = NSTimeZone(name: "UTC")

                self.subject = NewsFeedController(
                    newsItemRepository: self.newsItemRepository,
                    imageRepository: self.imageRepository,
                    dateFormatter: dateFormatter,
                    newsItemControllerProvider: self.newsItemControllerProvider,
                    settingsController: self.settingsController,
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

                expect(self.tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "newsTabBarIcon")))
                expect(self.tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "newsTabBarIconInactive")))
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

            it("styles the spinner from the theme") {
                expect(self.subject.loadingIndicatorView.color).to(equal(UIColor.greenColor()))
            }

            it("sets the spinner up to hide when stopped") {
                expect(self.subject.loadingIndicatorView.hidesWhenStopped).to(equal(true))
            }

            describe("tapping on the settings button") {
                beforeEach {
                    self.subject.navigationItem.rightBarButtonItem!.tap()
                }

                it("should push the settings controller onto the nav stack") {
                    expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.settingsController))
                }

                it("tracks a custom event via the analytics service") {
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Settings' in News nav bar"))
                    expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                }
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
                    let newsItemA = NewsItem(title: "Bernie to release new album", date: newsItemADate, body: "yeahhh", imageURL: NSURL(string: "http://bs.com")!, URL: NSURL())
                    let newsItemB = NewsItem(title: "Bernie up in the polls!", date: newsItemBDate, body: "body text", imageURL: NSURL(), URL: NSURL())

                    let newsItems = [newsItemA, newsItemB]

                    it("has 2 sections") {
                        self.newsItemRepository.lastCompletionBlock!(newsItems)

                        expect(self.subject.tableView.numberOfSections).to(equal(2))
                    }

                    it("shows the table view, and stops the loading spinner") {
                        self.newsItemRepository.lastCompletionBlock!(newsItems)

                        expect(self.subject.tableView.hidden).to(equal(false));
                        expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(false))
                    }

                    describe("the top news story") {
                        var cell : NewsHeadlineTableViewCell!

                        it("shows the first news item as a headline news cell") {
                            self.newsItemRepository.lastCompletionBlock!(newsItems)

                            expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(1))

                            cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsHeadlineTableViewCell
                            expect(cell.titleLabel.text).to(equal("Bernie to release new album"))
                        }

                        it("styles the cell") {
                            self.newsItemRepository.lastCompletionBlock!(newsItems)
                            cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsHeadlineTableViewCell

                            expect(cell.titleLabel.textColor).to(equal(UIColor.yellowColor()))
                            expect(cell.titleLabel.font).to(equal(UIFont.systemFontOfSize(666)))
                            expect(cell.titleLabel.backgroundColor).to(equal(UIColor.orangeColor()))
                        }

                        context("when the first news item has an image URL") {

                            beforeEach() {
                                self.newsItemRepository.lastCompletionBlock!(newsItems)

                                cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsHeadlineTableViewCell
                            }

                            it("sets a placeholder image") {
                                let placeholderImage = UIImage(named: "newsHeadlinePlaceholder")!
                                let expectedImageData = UIImagePNGRepresentation(placeholderImage)
                                let headlineImageData = UIImagePNGRepresentation(cell.headlineImageView.image!)

                                expect(headlineImageData).to(equal(expectedImageData))
                            }

                            it("makes a request for the image") {
                                expect(self.imageRepository.imageRequested).to(beTrue())
                                expect(self.imageRepository.lastReceivedURL).to(beIdenticalTo(newsItemA.imageURL))
                            }

                            context("when the image loads successfully") {
                                it("shows the loaded image in the image view") {
                                    let storyImage = TestUtils.testImageNamed("bernie", type: "jpg")

                                    self.imageRepository.lastRequestDeferred.resolveWithValue(storyImage)

                                    let expectedImageData = UIImagePNGRepresentation(storyImage)
                                    let storyImageData = UIImagePNGRepresentation(cell.headlineImageView.image!)

                                    expect(storyImageData).to(equal(expectedImageData))
                                }
                            }

                            context("when the image cannot be loaded") {
                                it("still shows the placeholder image") {
                                    let placeholderImage = UIImage(named: "newsHeadlinePlaceholder")!
                                    let expectedImageData = UIImagePNGRepresentation(placeholderImage)
                                    let headlineImageData = UIImagePNGRepresentation(cell.headlineImageView.image!)

                                    expect(headlineImageData).to(equal(expectedImageData))
                                }
                            }
                        }

                        context("when the first news item does not have an image URL") {
                            beforeEach {
                                let newsItemWithoutImage =  NewsItem(title: "no pics", date: newsItemADate, body: "nope", imageURL: nil, URL: NSURL())

                                self.newsItemRepository.lastCompletionBlock!([newsItemWithoutImage])

                                cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! NewsHeadlineTableViewCell
                            }

                            it("sets a default image") {
                                let defaultImage = UIImage(named: "newsHeadlinePlaceholder")!
                                let expectedImageData = UIImagePNGRepresentation(defaultImage)
                                let headlineImageData = UIImagePNGRepresentation(cell.headlineImageView.image!)

                                expect(headlineImageData).to(equal(expectedImageData))
                            }

                            it("does not make a request for an image") {
                                expect(self.imageRepository.imageRequested).to(beFalse())
                            }
                        }
                    }

                    describe("the rest of the news story") {
                        beforeEach {
                            self.newsItemRepository.lastCompletionBlock!(newsItems)
                        }

                        it("shows the items in the table with upcased text") {
                            expect(self.subject.tableView.numberOfRowsInSection(1)).to(equal(1))

                            let cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! TitleSubTitleTableViewCell
                            expect(cellB.titleLabel.text).to(equal("Bernie up in the polls!"))
                            expect(cellB.dateLabel.text).to(equal("1/2/70"))
                        }

                        it("styles the items in the table") {
                            let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! TitleSubTitleTableViewCell

                            expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                            expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                            expect(cell.dateLabel.textColor).to(equal(UIColor.brownColor()))
                            expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
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
                }
            }

            describe("Tapping on a news item") {
                let expectedNewsItemA = NewsItem(title: "A", date: NSDate(), body: "A Body", imageURL: NSURL(), URL: NSURL(string: "http://example.com/a")!)
                let expectedNewsItemB = NewsItem(title: "B", date: NSDate(), body: "B Body", imageURL: NSURL(), URL: NSURL(string: "http://example.com/b")!)
                beforeEach {
                    self.subject.viewWillAppear(false)

                    let newsItems = [expectedNewsItemA, expectedNewsItemB]

                    self.newsItemRepository.lastCompletionBlock!(newsItems)
                }

                afterEach {
                    self.navigationController.popViewControllerAnimated(false)
                }

                context("that is the headline news story") {
                    beforeEach {
                        let tableView = self.subject.tableView
                        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                    }

                    it("tracks the content view with the analytics service") {
                        expect(self.analyticsService.lastContentViewName).to(equal(expectedNewsItemA.title))
                        expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.NewsItem))
                        expect(self.analyticsService.lastContentViewID).to(equal(expectedNewsItemA.URL.absoluteString))
                    }

                    it("should push a correctly configured news item view controller onto the nav stack") {
                        expect(self.newsItemControllerProvider.lastNewsItem).to(beIdenticalTo(expectedNewsItemA))
                        expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.newsItemControllerProvider.controller))
                    }
                }

                context("that is another news story") {
                    beforeEach {
                        let tableView = self.subject.tableView
                        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
                    }

                    it("should push a correctly configured news item view controller onto the nav stack") {
                        expect(self.newsItemControllerProvider.lastNewsItem).to(beIdenticalTo(expectedNewsItemB))
                        expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.newsItemControllerProvider.controller))
                    }

                    it("tracks the content view with the analytics service") {
                        expect(self.analyticsService.lastContentViewName).to(equal(expectedNewsItemB.title))
                        expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.NewsItem))
                        expect(self.analyticsService.lastContentViewID).to(equal(expectedNewsItemB.URL.absoluteString))
                    }
                }
            }
        }
    }
}

