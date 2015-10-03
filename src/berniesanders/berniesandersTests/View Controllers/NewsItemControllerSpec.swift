import UIKit
import Quick
import Nimble
import berniesanders

class NewsItemFakeTheme : FakeTheme {
    override func newsItemDateFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }
    
    override func newsItemDateColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    override func newsItemTitleFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)
    }
    
    override func newsItemTitleColor() -> UIColor {
        return UIColor.brownColor()
    }
    
    override func newsItemBodyFont() -> UIFont {
        return UIFont.systemFontOfSize(3)
    }
    
    override func newsItemBodyColor() -> UIColor {
        return UIColor.yellowColor()
    }
    
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }
}

class NewsItemControllerSpec : QuickSpec {
    var subject: NewsItemController!
    let newsItemImageURL = NSURL(string: "http://a.com")!
    let newsItemURL = NSURL(string: "http//b.com")!
    let newsItemDate = NSDate(timeIntervalSince1970: 1441081523)
    var newsItem : NewsItem!
    var imageRepository : FakeImageRepository!
    let dateFormatter = NSDateFormatter()
    var analyticsService: FakeAnalyticsService!
    let theme = NewsItemFakeTheme()
    
    override func spec() {
        describe("NewsItemController") {
            beforeEach {
                self.imageRepository = FakeImageRepository()
                self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                self.dateFormatter.timeZone = NSTimeZone(name: "UTC")
                self.analyticsService = FakeAnalyticsService()
            }
            
            context("with a standard news item") {
                beforeEach {
                    self.newsItem = NewsItem(title: "some title", date: self.newsItemDate, body: "some body text", imageURL: self.newsItemImageURL, URL:self.newsItemURL)
                    
                    self.subject = NewsItemController(
                        newsItem: self.newsItem,
                        imageRepository: self.imageRepository,
                        dateFormatter: self.dateFormatter,
                        analyticsService: self.analyticsService,
                        theme: self.theme
                    )
                }
                
                it("tracks taps on the back button with the analytics service") {
                    self.subject.didMoveToParentViewController(nil)
                    
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Back' on News Item"))
                    let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString!]
                    expect(self.analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                }
                
                it("should hide the tab bar when pushed") {
                    expect(self.subject.hidesBottomBarWhenPushed).to(beTrue())
                }
                
                describe("when the view loads") {
                    beforeEach {
                        self.subject.view.layoutIfNeeded()
                    }
                    
                    it("has a share button on the navigation item") {
                        var shareBarButtonItem = self.subject.navigationItem.rightBarButtonItem!
                        expect(shareBarButtonItem.valueForKey("systemItem") as? Int).to(equal(UIBarButtonSystemItem.Action.rawValue))
                    }
                    
                    it("sets up the body text view not to be editable") {
                        expect(self.subject.bodyTextView.editable).to(beFalse())
                    }
                    
                    describe("tapping on the share button") {
                        beforeEach {
                            self.subject.navigationItem.rightBarButtonItem!.tap()
                        }
                        
                        it("should present an activity view controller for sharing the story URL") {
                            
                            let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                            let activityItems = activityViewControler.activityItems()
                            
                            expect(activityItems.count).to(equal(1))
                            expect(activityItems.first as? NSURL).to(beIdenticalTo(self.newsItemURL))
                        }
                        
                        it("logs that the user tapped share") {
                            expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Share' on News Item"))
                            let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString!]
                            expect(self.analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }

                        context("and the user completes the share succesfully") {
                            it("tracks the share via the analytics service") {
                                let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                                activityViewControler.completionWithItemsHandler!("Some activity", true, nil, nil)
                            
                                expect(self.analyticsService.lastShareActivityType).to(equal("Some activity"))
                                expect(self.analyticsService.lastShareContentName).to(equal(self.newsItem.title))
                                expect(self.analyticsService.lastShareContentType).to(equal(AnalyticsServiceContentType.NewsItem))
                                expect(self.analyticsService.lastShareID).to(equal(self.newsItemURL.absoluteString))
                            }
                        }
                        
                        context("and the user cancels the share") {
                            it("tracks the share cancellation via the analytics service") {
                                let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                                activityViewControler.completionWithItemsHandler!(nil, false, nil, nil)
                                
                                expect(self.analyticsService.lastCustomEventName).to(equal("Cancelled share of News Item"))
                                let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString!]
                                expect(self.analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                            }
                        }
                        
                        context("and there is an error when sharing") {
                            it("tracks the error via the analytics service") {
                                let expectedError = NSError(domain: "a", code: 0, userInfo: nil)
                                let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                                activityViewControler.completionWithItemsHandler!("asdf", true, nil, expectedError)
                                
                                expect(self.analyticsService.lastError).to(beIdenticalTo(expectedError))
                                expect(self.analyticsService.lastErrorContext).to(equal("Failed to share News Item"))
                            }
                        }
                    }
                    
                    it("has a scroll view containing the UI elements") {
                        expect(self.subject.view.subviews.count).to(equal(1))
                        var scrollView = self.subject.view.subviews.first as! UIScrollView
                        
                        expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                        expect(scrollView.subviews.count).to(equal(1))
                        
                        var containerView = scrollView.subviews.first as! UIView
                        
                        expect(containerView.subviews.count).to(equal(4))
                        
                        var containerViewSubViews = containerView.subviews as! [UIView]
                        
                        expect(contains(containerViewSubViews, self.subject.titleLabel)).to(beTrue())
                        expect(contains(containerViewSubViews, self.subject.bodyTextView)).to(beTrue())
                        expect(contains(containerViewSubViews, self.subject.dateLabel)).to(beTrue())
                        expect(contains(containerViewSubViews, self.subject.storyImageView)).to(beTrue())
                    }
                    
                    it("displays the title from the news item") {
                        expect(self.subject.titleLabel.text).to(equal("some title"))
                    }
                    
                    it("displays the story body") {
                        expect(self.subject.bodyTextView.text).to(equal("some body text"))
                    }
                    
                    it("displays the date") {
                        expect(self.subject.dateLabel.text).to(equal("9/1/15"))
                    }
                    
                    it("makes a request for the story's image") {
                        expect(self.imageRepository.lastReceivedURL).to(beIdenticalTo(self.newsItemImageURL))
                    }
                    
                    it("styles the views according to the theme") {
                        expect(self.subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                        expect(self.subject.dateLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                        expect(self.subject.dateLabel.textColor).to(equal(UIColor.magentaColor()))
                        expect(self.subject.titleLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                        expect(self.subject.titleLabel.textColor).to(equal(UIColor.brownColor()))
                        expect(self.subject.bodyTextView.font).to(equal(UIFont.systemFontOfSize(3)))
                        expect(self.subject.bodyTextView.textColor).to(equal(UIColor.yellowColor()))
                    }
                    
                    context("when the request for the story's image succeeds") {
                        it("displays the image") {
                            var storyImage = TestUtils.testImageNamed("bernie", type: "jpg")
                            
                            self.imageRepository.lastRequestDeferred.resolveWithValue(storyImage)
                            
                            var expectedImageData = UIImagePNGRepresentation(storyImage)
                            var storyImageData = UIImagePNGRepresentation(self.subject.storyImageView.image)
                            
                            expect(storyImageData).to(equal(expectedImageData))
                        }
                    }
                    
                    context("when the request for the story's image fails") {
                        it("removes the image view from the container") {
                            self.imageRepository.lastRequestDeferred.rejectWithError(nil)
                            var scrollView = self.subject.view.subviews.first as! UIScrollView
                            var containerView = scrollView.subviews.first as! UIView
                            var containerViewSubViews = containerView.subviews as! [UIView]
                            
                            expect(contains(containerViewSubViews, self.subject.storyImageView)).to(beFalse())
                        }
                    }
                }
            }
            
            context("with a news item that lacks an image") {
                beforeEach {
                    let newsItemDate = NSDate(timeIntervalSince1970: 1441081523)
                    let newsItem = NewsItem(title: "some title", date: newsItemDate, body: "some body text", imageURL: nil, URL:self.newsItemURL)
                    
                    self.subject = NewsItemController(
                        newsItem: newsItem,
                        imageRepository: self.imageRepository,
                        dateFormatter: self.dateFormatter,
                        analyticsService: self.analyticsService,
                        theme: self.theme
                    )
                    
                    self.subject.view.layoutIfNeeded()
                }
                
                it("should not make a request for the story's image") {
                    expect(self.imageRepository.imageRequested).to(beFalse())
                }
                
                it("removes the image view from the container") {
                    var scrollView = self.subject.view.subviews.first as! UIScrollView
                    var containerView = scrollView.subviews.first as! UIView
                    var containerViewSubViews = containerView.subviews as! [UIView]
                    
                    expect(contains(containerViewSubViews, self.subject.storyImageView)).to(beFalse())
                }
            }
        }
    }
}
