import UIKit
import Quick
import Nimble

@testable import Movement

class NewsArticleControllerSpec : QuickSpec {
    override func spec() {
        describe("NewsArticleController") {
            var subject: NewsArticleController!
            let newsArticleImageURL = NSURL(string: "http://a.com")!
            let newsArticleURL = NSURL(string: "http//b.com")!
            let newsArticleDate = NSDate(timeIntervalSince1970: 1441081523)
            var newsArticle: NewsArticle!
            var imageService: FakeImageService!
            var timeIntervalFormatter: FakeTimeIntervalFormatter!
            var analyticsService: FakeAnalyticsService!
            var urlOpener: FakeURLOpener!
            var urlAttributionPresenter: FakeURLAttributionPresenter!
            let theme = NewsArticleFakeTheme()

            beforeEach {
                imageService = FakeImageService()
                timeIntervalFormatter = FakeTimeIntervalFormatter()
                analyticsService = FakeAnalyticsService()
                urlOpener = FakeURLOpener()
                urlAttributionPresenter = FakeURLAttributionPresenter()
            }

            context("with a standard news item") {
                beforeEach {
                    newsArticle = NewsArticle(title: "some title", date: newsArticleDate, body: "some body text", excerpt: "excerpt", imageURL: newsArticleImageURL, url:newsArticleURL)

                    subject = NewsArticleController(
                        newsArticle: newsArticle,
                        imageService: imageService,
                        timeIntervalFormatter: timeIntervalFormatter,
                        analyticsService: analyticsService,
                        urlOpener: urlOpener,
                        urlAttributionPresenter: urlAttributionPresenter,
                        theme: theme
                    )
                }

                it("tracks taps on the back button with the analytics service") {
                    subject.didMoveToParentViewController(UIViewController())

                    expect(analyticsService.lastBackButtonTapScreen).to(beNil())

                    subject.didMoveToParentViewController(nil)

                    expect(analyticsService.lastBackButtonTapScreen).to(equal("News Item"))
                    let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: newsArticle.url.absoluteString]
                    expect(analyticsService.lastBackButtonTapAttributes! as? [String: String]).to(equal(expectedAttributes))
                }

                it("should hide the tab bar when pushed") {
                    expect(subject.hidesBottomBarWhenPushed).to(beTrue())
                }

                describe("when the view loads") {
                    beforeEach {
                        subject.view.layoutIfNeeded()
                    }

                    it("has a share button on the navigation item") {
                        let shareBarButtonItem = subject.navigationItem.rightBarButtonItem!
                        expect(shareBarButtonItem.title).to(equal("Share"))
                    }

                    it("sets up the body text view not to be editable") {
                        expect(subject.bodyTextView.editable).to(beFalse())
                    }

                    describe("tapping on the share button") {
                        beforeEach {
                            subject.navigationItem.rightBarButtonItem!.tap()
                        }

                        it("should present an activity view controller for sharing the story URL") {

                            let activityViewControler = subject.presentedViewController as! UIActivityViewController
                            let activityItems = activityViewControler.activityItems()

                            expect(activityItems.count).to(equal(1))
                            expect(activityItems.first as? NSURL).to(beIdenticalTo(newsArticleURL))
                        }

                        it("logs that the user tapped share") {
                            expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: newsArticle.url.absoluteString,
                                AnalyticsServiceConstants.contentNameKey: newsArticle.title,
                                AnalyticsServiceConstants.contentTypeKey: "News Article"
                            ]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }

                        context("and the user completes the share succesfully") {
                            it("tracks the share via the analytics service") {
                                let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                activityViewControler.completionWithItemsHandler!("Some activity", true, nil, nil)

                                expect(analyticsService.lastShareActivityType).to(equal("Some activity"))
                                expect(analyticsService.lastShareContentName).to(equal(newsArticle.title))
                                expect(analyticsService.lastShareContentType).to(equal(AnalyticsServiceContentType.NewsArticle))
                                expect(analyticsService.lastShareID).to(equal(newsArticleURL.absoluteString))
                            }
                        }

                        context("and the user cancels the share") {
                            it("tracks the share cancellation via the analytics service") {
                                let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                activityViewControler.completionWithItemsHandler!(nil, false, nil, nil)

                                expect(analyticsService.lastCustomEventName).to(equal("Cancelled Share"))
                                let expectedAttributes = [
                                    AnalyticsServiceConstants.contentIDKey: newsArticle.url.absoluteString,
                                    AnalyticsServiceConstants.contentNameKey: newsArticle.title,
                                    AnalyticsServiceConstants.contentTypeKey: "News Article"
                                ]
                                expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                            }
                        }

                        context("and there is an error when sharing") {
                            it("tracks the error via the analytics service") {
                                let expectedError = NSError(domain: "a", code: 0, userInfo: nil)
                                let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                activityViewControler.completionWithItemsHandler!("asdf", true, nil, expectedError)

                                expect(analyticsService.lastError as NSError).to(beIdenticalTo(expectedError))
                                expect(analyticsService.lastErrorContext).to(equal("Failed to share News Item"))
                            }
                        }
                    }

                    it("has a scroll view containing the UI elements") {
                        expect(subject.view.subviews.count).to(equal(1))
                        let scrollView = subject.view.subviews.first as! UIScrollView

                        expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                        expect(scrollView.subviews.count).to(equal(1))

                        let containerView = scrollView.subviews.first!

                        expect(containerView.subviews.count).to(equal(6))

                        let containerViewSubViews = containerView.subviews

                        expect(containerViewSubViews.contains(subject.titleLabel)).to(beTrue())
                        expect(containerViewSubViews.contains(subject.bodyTextView)).to(beTrue())
                        expect(containerViewSubViews.contains(subject.dateLabel)).to(beTrue())
                        expect(containerViewSubViews.contains(subject.storyImageView)).to(beTrue())
                    }

                    it("displays the title from the news item") {
                        expect(subject.titleLabel.text).to(equal("some title"))
                    }

                    it("displays the story body") {
                        expect(subject.bodyTextView.text).to(equal("some body text"))
                    }

                    it("displays the date using the human date formatter") {
                        expect(timeIntervalFormatter.lastFormattedDate).to(beIdenticalTo(newsArticleDate))
                        expect(subject.dateLabel.text).to(equal("human date"))
                    }

                    it("uses the presenter to get attribution text for the issue") {
                        expect(urlAttributionPresenter.lastPresentedURL).to(beIdenticalTo(newsArticle.url))
                        expect(subject.attributionLabel.text).to(equal(urlAttributionPresenter.returnedText))
                    }

                    it("has a button to view the original issue") {
                        expect(subject.viewOriginalButton.imageForState(.Normal)).to(equal(UIImage(named: "ViewOriginal")))
                    }

                    describe("tapping on the view original button") {
                        beforeEach {
                            subject.viewOriginalButton.tap()
                        }

                        it("opens the original issue in safari") {
                            expect(urlOpener.lastOpenedURL).to(beIdenticalTo(newsArticle.url))
                        }

                        it("logs that the user tapped view original") {
                            expect(analyticsService.lastCustomEventName).to(equal("Tapped 'View Original' on News Item"))
                            let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: newsArticle.url.absoluteString]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }

                    it("makes a request for the story's image") {
                        expect(imageService.lastReceivedURL).to(beIdenticalTo(newsArticleImageURL))
                    }

                    it("styles the views according to the theme") {
                        expect(subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                        expect(subject.dateLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                        expect(subject.dateLabel.textColor).to(equal(UIColor.magentaColor()))
                        expect(subject.titleLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                        expect(subject.titleLabel.textColor).to(equal(UIColor.brownColor()))
                        expect(subject.bodyTextView.font).to(equal(UIFont.systemFontOfSize(3)))
                        expect(subject.bodyTextView.textColor).to(equal(UIColor.yellowColor()))
                        expect(subject.attributionLabel.textColor).to(equal(UIColor.greenColor()))
                        expect(subject.attributionLabel.font).to(equal(UIFont.boldSystemFontOfSize(111)))
                        expect(subject.viewOriginalButton.backgroundColor).to(equal(UIColor.redColor()))
                    }

                    context("when the request for the story's image succeeds") {
                        it("displays the image") {
                            let storyImage = TestUtils.testImageNamed("bernie", type: "jpg")
                            let expectedImageData = UIImagePNGRepresentation(storyImage)

                            imageService.lastRequestPromise.resolve(storyImage)

                            let storyImageData = UIImagePNGRepresentation(subject.storyImageView.image!)

                            expect(storyImageData).to(equal(expectedImageData))
                        }
                    }

                    context("when the request for the story's image fails") {
                        it("removes the image view from the container") {
                            let error = ImageRepositoryError.DownloadError(error: NSError(domain: "", code: 0, userInfo: nil))

                            imageService.lastRequestPromise.reject(error)
                            let scrollView = subject.view.subviews.first!
                            let containerView = scrollView.subviews.first!
                            let containerViewSubViews = containerView.subviews

                            expect(containerViewSubViews.contains(subject.storyImageView)).to(beFalse())
                        }
                    }
                }
            }

            context("with a news item that lacks an image") {
                beforeEach {
                    let newsArticleDate = NSDate(timeIntervalSince1970: 1441081523)
                    let newsArticle = NewsArticle(title: "some title", date: newsArticleDate, body: "some body text", excerpt: "excerpt", imageURL: nil, url:newsArticleURL)

                    subject = NewsArticleController(
                        newsArticle: newsArticle,
                        imageService: imageService,
                        timeIntervalFormatter: timeIntervalFormatter,
                        analyticsService: analyticsService,
                        urlOpener: urlOpener,
                        urlAttributionPresenter: urlAttributionPresenter,
                        theme: theme
                    )

                    subject.view.layoutIfNeeded()
                }

                it("should not make a request for the story's image") {
                    expect(imageService.imageRequested).to(beFalse())
                }

                it("removes the image view from the container") {
                    let scrollView = subject.view.subviews.first!
                    let containerView = scrollView.subviews.first!
                    let containerViewSubViews = containerView.subviews

                    expect(containerViewSubViews.contains(subject.storyImageView)).to(beFalse())
                }
            }
        }
    }
}

private class NewsArticleFakeTheme: FakeTheme {
    override func newsArticleDateFont() -> UIFont { return UIFont.boldSystemFontOfSize(20) }
    override func newsArticleDateColor() -> UIColor { return UIColor.magentaColor() }
    override func newsArticleTitleFont() -> UIFont { return UIFont.italicSystemFontOfSize(13) }
    override func newsArticleTitleColor() -> UIColor { return UIColor.brownColor() }
    override func newsArticleBodyFont() -> UIFont { return UIFont.systemFontOfSize(3) }
    override func newsArticleBodyColor() -> UIColor { return UIColor.yellowColor() }
    override func contentBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func attributionFont() -> UIFont { return UIFont.boldSystemFontOfSize(111) }
    override func attributionTextColor() -> UIColor { return UIColor.greenColor() }
    override func attributionButtonBackgroundColor() -> UIColor { return UIColor.redColor() }
    override func defaultButtonTextColor() -> UIColor { return UIColor.blueColor() }
    override func defaultButtonFont() -> UIFont { return UIFont.boldSystemFontOfSize(222) }
    override func defaultBodyTextLineHeight() -> CGFloat { return 666.0 }
    override func defaultButtonBorderColor() -> UIColor { return UIColor.whiteColor() }
}
