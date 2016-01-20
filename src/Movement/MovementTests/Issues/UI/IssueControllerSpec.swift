import UIKit
import Quick
import Nimble

@testable import Movement

class IssueControllerSpec : QuickSpec {
    override func spec() {
        describe("IssueController") {
            var subject : IssueController!
            var imageService : FakeImageService!
            var analyticsService: FakeAnalyticsService!
            var urlOpener: FakeURLOpener!
            var urlAttributionPresenter: FakeURLAttributionPresenter!
            let issue = TestUtils.issue()

            context("with a standard issue") {
                beforeEach {
                    imageService = FakeImageService()
                    analyticsService = FakeAnalyticsService()
                    urlOpener = FakeURLOpener()
                    urlAttributionPresenter = FakeURLAttributionPresenter()

                    subject = IssueController(
                        issue: issue,
                        imageService: imageService,
                        analyticsService: analyticsService,
                        urlOpener: urlOpener,
                        urlAttributionPresenter: urlAttributionPresenter,
                        theme: IssueFakeTheme())
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
                            expect(activityItems.first as? NSURL).to(beIdenticalTo(issue.url))
                        }

                        it("logs that the user tapped share") {
                            expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString,
                                AnalyticsServiceConstants.contentNameKey: issue.title,
                                AnalyticsServiceConstants.contentTypeKey: "Issue"
                            ]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }

                        context("and the user completes the share succesfully") {
                            it("tracks the share via the analytics service") {
                                let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                activityViewControler.completionWithItemsHandler!("Some activity", true, nil, nil)

                                expect(analyticsService.lastShareActivityType).to(equal("Some activity"))
                                expect(analyticsService.lastShareContentName).to(equal(issue.title))
                                expect(analyticsService.lastShareContentType).to(equal(AnalyticsServiceContentType.Issue))
                                expect(analyticsService.lastShareID).to(equal(issue.url.absoluteString))
                            }
                        }

                        context("and the user cancels the share") {
                            it("tracks the share cancellation via the analytics service") {
                                let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                activityViewControler.completionWithItemsHandler!(nil, false, nil, nil)

                                expect(analyticsService.lastCustomEventName).to(equal("Cancelled Share"))
                                let expectedAttributes = [
                                    AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString,
                                    AnalyticsServiceConstants.contentNameKey: issue.title,
                                    AnalyticsServiceConstants.contentTypeKey: "Issue"
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
                                expect(analyticsService.lastErrorContext).to(equal("Failed to share Issue"))
                            }
                        }
                    }

                    it("has a scroll view containing the UI elements") {
                        expect(subject.view.subviews.count).to(equal(1))
                        let scrollView = subject.view.subviews.first as! UIScrollView

                        expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                        expect(scrollView.subviews.count).to(equal(1))

                        let containerView = scrollView.subviews.first!

                        expect(containerView.subviews.count).to(equal(5))

                        let containerViewSubViews = containerView.subviews

                        expect(containerViewSubViews.contains(subject.issueImageView)).to(beTrue())
                        expect(containerViewSubViews.contains(subject.bodyTextView)).to(beTrue())
                        expect(containerViewSubViews.contains(subject.attributionLabel)).to(beTrue())
                        expect(containerViewSubViews.contains(subject.viewOriginalButton)).to(beTrue())
                    }

                    it("styles the views according to the theme") {
                        expect(subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                        expect(subject.titleLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                        expect(subject.titleLabel.textColor).to(equal(UIColor.brownColor()))
                        expect(subject.bodyTextView.font).to(equal(UIFont.systemFontOfSize(3)))
                        expect(subject.bodyTextView.textColor).to(equal(UIColor.yellowColor()))
                        expect(subject.attributionLabel.font).to(equal(UIFont.systemFontOfSize(222)))
                        expect(subject.attributionLabel.textColor).to(equal(UIColor.magentaColor()))
                        expect(subject.viewOriginalButton.backgroundColor).to(equal(UIColor.greenColor()))
                        expect(subject.viewOriginalButton.titleColorForState(.Normal)).to(equal(UIColor.redColor()))
                        expect(subject.viewOriginalButton.titleLabel!.font).to(equal(UIFont.systemFontOfSize(333)))
                    }

                    it("displays the title from the issue as a button") {
                        expect(subject.titleLabel.text).to(equal("An issue title made by TestUtils"))
                    }

                    it("displays the issue body") {
                        expect(subject.bodyTextView.text).to(equal("An issue body made by TestUtils"))
                    }

                    it("uses the presenter to get attribution text for the issue") {
                        expect(urlAttributionPresenter.lastPresentedURL).to(beIdenticalTo(issue.url))
                        expect(subject.attributionLabel.text).to(equal(urlAttributionPresenter.returnedText))
                    }

                    it("has a button to view the original issue") {
                        expect(subject.viewOriginalButton.titleForState(.Normal)).to(equal("View Original"))
                    }

                    describe("tapping on the view original button") {
                        beforeEach {
                            subject.viewOriginalButton.tap()
                        }

                        it("opens the original issue in safari") {
                            expect(urlOpener.lastOpenedURL).to(beIdenticalTo(issue.url))
                        }

                        it("logs that the user tapped view original") {
                            expect(analyticsService.lastCustomEventName).to(equal("Tapped 'View Original' on Issue"))
                            let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString]
                            expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                        }
                    }

                    it("makes a request for the story's image") {
                        expect(imageService.lastReceivedURL).to(beIdenticalTo(issue.imageURL))
                    }

                    context("when the request for the story's image succeeds") {
                        it("displays the image") {
                            let issueImage = TestUtils.testImageNamed("bernie", type: "jpg")
                            let expectedImageData = UIImagePNGRepresentation(issueImage)

                            imageService.lastRequestPromise.resolve(issueImage)
                            let storyImageData = UIImagePNGRepresentation(subject.issueImageView.image!)
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

                            expect(containerViewSubViews.contains(subject.issueImageView)).to(beFalse())
                        }
                    }
                }

                context("with an issue that lacks an image") {
                    beforeEach {
                        let issue = Issue(title: "Some issue", body: "body", imageURL: nil, url: NSURL(string: "http://b.com")!)

                        subject = IssueController(
                            issue: issue,
                            imageService: imageService,
                            analyticsService: analyticsService,
                            urlOpener: urlOpener,
                            urlAttributionPresenter: urlAttributionPresenter,
                            theme: IssueFakeTheme())


                        subject.view.layoutIfNeeded()
                    }

                    it("should not make a request for the story's image") {
                        expect(imageService.imageRequested).to(beFalse())
                    }

                    it("removes the image view from the container") {
                        let scrollView = subject.view.subviews.first as! UIScrollView
                        let containerView = scrollView.subviews.first!
                        let containerViewSubViews = containerView.subviews

                        expect(containerViewSubViews.contains(subject.issueImageView)).to(beFalse())
                    }
                }
            }
        }
    }
}

class IssueFakeTheme : FakeTheme {
    override func issueTitleFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)
    }

    override func issueTitleColor() -> UIColor {
        return UIColor.brownColor()
    }

    override func issueBodyFont() -> UIFont {
        return UIFont.systemFontOfSize(3)
    }

    override func issueBodyColor() -> UIColor {
        return UIColor.yellowColor()
    }

    override func contentBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }

    override func attributionFont() -> UIFont {
        return UIFont.systemFontOfSize(222)
    }

    override func attributionTextColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func defaultButtonBackgroundColor() -> UIColor { return UIColor.greenColor() }
    override func defaultButtonTextColor() -> UIColor { return UIColor.redColor() }
    override func defaultButtonFont() -> UIFont { return UIFont.systemFontOfSize(333) }
}
