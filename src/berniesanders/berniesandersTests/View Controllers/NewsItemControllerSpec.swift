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
    var imageRepository : FakeImageRepository!
    let newsItemImageURL = NSURL(string: "http://a.com")!
    let newsItemURL = NSURL(string: "http//b.com")!
    let dateFormatter = NSDateFormatter()
    let theme = NewsItemFakeTheme()
    
    override func spec() {
        describe("NewsItemController") {
            beforeEach {
                self.imageRepository = FakeImageRepository()
                self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                self.dateFormatter.timeZone = NSTimeZone(name: "UTC")
            }
            
            context("with a standard news item") {
                beforeEach {
                    let newsItemDate = NSDate(timeIntervalSince1970: 1441081523)
                    let newsItem = NewsItem(title: "some title", date: newsItemDate, body: "some body text", imageURL: self.newsItemImageURL, URL:self.newsItemURL)
                    
                    self.subject = NewsItemController(
                        newsItem: newsItem,
                        dateFormatter: self.dateFormatter,
                        imageRepository: self.imageRepository,
                        theme: self.theme
                    )
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
                        it("should present an activity view controller for sharing the story URL") {
                            self.subject.navigationItem.rightBarButtonItem!.tap()
                            
                            let activityViewControler = self.subject.presentedViewController as! UIActivityViewController
                            let activityItems = activityViewControler.activityItems()
                            
                            expect(activityItems.count).to(equal(1))
                            expect(activityItems.first as? NSURL).to(beIdenticalTo(self.newsItemURL))
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
                        dateFormatter: self.dateFormatter,
                        imageRepository: self.imageRepository,
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
