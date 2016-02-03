import Quick
import Nimble
import MediaPlayer
import XCDYouTubeKit

@testable import Movement

class VideoControllerSpec: QuickSpec {
    override func spec() {
        describe("VideoController") {
            var subject: VideoController!
            var video: Video!
            var timeIntervalFormatter: FakeTimeIntervalFormatter!
            var urlProvider: VideoFakeURLProvider!
            var urlOpener: FakeURLOpener!
            var urlAttributionPresenter: FakeURLAttributionPresenter!
            var analyticsService: FakeAnalyticsService!
            let theme = VideoFakeTheme()
            let videoDate = NSDate(timeIntervalSince1970: 1450806042)

            beforeEach {
                video = Video(title: "Happy Dance", date: videoDate, identifier: "FGHmzu9Dz18", description: "yay, happy!")
                timeIntervalFormatter = FakeTimeIntervalFormatter()
                urlProvider = VideoFakeURLProvider()
                urlOpener = FakeURLOpener()
                urlAttributionPresenter = FakeURLAttributionPresenter()
                analyticsService = FakeAnalyticsService()

                subject = VideoController(video: video,
                    timeIntervalFormatter: timeIntervalFormatter,
                    urlProvider: urlProvider,
                    urlOpener: urlOpener,
                    urlAttributionPresenter: urlAttributionPresenter,
                    analyticsService: analyticsService,
                    theme: theme)
            }

            describe("When the view loads") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("styles the view from the theme") {
                    expect(subject.view.backgroundColor).to(equal(UIColor.magentaColor()))
                    expect(subject.dateLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                    expect(subject.dateLabel.textColor).to(equal(UIColor.redColor()))
                    expect(subject.titleLabel.font).to(equal(UIFont.systemFontOfSize(222)))
                    expect(subject.titleLabel.textColor).to(equal(UIColor.blueColor()))
                    expect(subject.descriptionTextView.font).to(equal(UIFont.systemFontOfSize(333)))
                    expect(subject.descriptionTextView.textColor).to(equal(UIColor.greenColor()))
                    expect(subject.attributionLabel.font).to(equal(UIFont.systemFontOfSize(444)))
                    expect(subject.attributionLabel.textColor).to(equal(UIColor.orangeColor()))
                    expect(subject.viewOriginalButton.backgroundColor).to(equal(UIColor.brownColor()))
                }

                it("has the view components as sub-views of a scroll view") {
                    expect(subject.view.subviews.count).to(equal(1))

                    let containerView = subject.view.subviews.first!.subviews.first!

                    expect(containerView.subviews.count).to(equal(6))
                    expect(containerView.subviews).to(contain(subject.titleLabel))
                    expect(containerView.subviews).to(contain(subject.descriptionTextView))
                    expect(containerView.subviews).to(contain(subject.dateLabel))
                    expect(containerView.subviews).to(contain(subject.videoView))
                    expect(containerView.subviews).to(contain(subject.attributionLabel))
                    expect(containerView.subviews).to(contain(subject.viewOriginalButton))
                }

                it("shows the title of the the video") {
                    expect(subject.titleLabel.text).to(equal("Happy Dance"))
                }

                it("shows the description of the video") {
                    expect(subject.descriptionTextView.text).to(equal("yay, happy!"))
                }

                it("shows the video date") {
                    expect(timeIntervalFormatter.lastFormattedDate).to(beIdenticalTo(videoDate))
                    expect(subject.dateLabel.text).to(equal("human date"))
                }

                it("sets up the video player with the video within the video view") {
                    expect(subject.videoView.subviews).to(contain(subject.videoController.view))
                    expect(subject.videoController.videoIdentifier!).to(equal(video.identifier))
                }

                it("sets up the video player to auto-play") {
                    expect(subject.videoController.moviePlayer.shouldAutoplay).to(beTrue())
                }

                xit("prepares the video player to play") {
                    // can't get this to work under test
                    expect(subject.videoController.moviePlayer.isPreparedToPlay).toEventually(beTrue())
                }

                it("uses the presenter to get attribution text for the issue") {
                    expect(urlProvider.lastIdentifier).to(equal(video.identifier))

                    expect(urlAttributionPresenter.lastPresentedURL).to(beIdenticalTo(urlProvider.lastReturnedURL))
                    expect(subject.attributionLabel.text).to(equal(urlAttributionPresenter.returnedText))
                }

                it("has a button to view the original video") {
                    expect(subject.viewOriginalButton.imageForState(.Normal)).to(equal(UIImage(named: "ViewOriginal")))
                }

                describe("tapping on the view original button") {
                    beforeEach {
                        subject.viewOriginalButton.tap()
                    }

                    it("opens the original video in safari") {
                        expect(urlProvider.lastIdentifier).to(equal(video.identifier))
                        expect(urlOpener.lastOpenedURL).to(beIdenticalTo(urlProvider.lastReturnedURL))
                    }

                    it("logs that the user tapped view original") {
                        expect(analyticsService.lastCustomEventName).to(equal("Tapped 'View Original' on Video"))
                        let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: video.identifier]
                        expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }
                }

                it("has a share button on the navigation item") {
                    let shareBarButtonItem = subject.navigationItem.rightBarButtonItem!
                    expect(shareBarButtonItem.title).to(equal("Share"))
                }

                describe("tapping on the share button") {
                    beforeEach {
                        subject.navigationItem.rightBarButtonItem!.tap()
                    }

                    it("should present an activity view controller for sharing the video URL") {

                        let activityViewControler = subject.presentedViewController as! UIActivityViewController
                        let activityItems = activityViewControler.activityItems()

                        expect(activityItems.count).to(equal(1))
                        expect(urlProvider.lastIdentifier).to(equal(video.identifier))
                        expect(activityItems.first as? NSURL).to(beIdenticalTo(urlProvider.lastReturnedURL))
                    }

                    it("tracks taps on the back button with the analytics service") {
                        subject.didMoveToParentViewController(UIViewController())

                        expect(analyticsService.lastBackButtonTapScreen).to(beNil())

                        subject.didMoveToParentViewController(nil)

                        expect(analyticsService.lastBackButtonTapScreen).to(equal("Video"))
                        let expectedAttributes = [ AnalyticsServiceConstants.contentIDKey: video.identifier]
                        expect(analyticsService.lastBackButtonTapAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }


                    it("logs that the user tapped share") {
                        expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                        let expectedAttributes = [
                            AnalyticsServiceConstants.contentIDKey: video.identifier,
                            AnalyticsServiceConstants.contentNameKey: video.title,
                            AnalyticsServiceConstants.contentTypeKey: "Video"
                        ]
                        expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                    }

                    context("and the user completes the share succesfully") {
                        it("tracks the share via the analytics service") {
                            let activityViewControler = subject.presentedViewController as! UIActivityViewController
                            activityViewControler.completionWithItemsHandler!("Some activity", true, nil, nil)

                            expect(analyticsService.lastShareActivityType).to(equal("Some activity"))
                            expect(analyticsService.lastShareContentName).to(equal(video.title))
                            expect(analyticsService.lastShareContentType).to(equal(AnalyticsServiceContentType.Video))
                            expect(analyticsService.lastShareID).to(equal(video.identifier))
                        }
                    }

                    context("and the user cancels the share") {
                        it("tracks the share cancellation via the analytics service") {
                            let activityViewControler = subject.presentedViewController as! UIActivityViewController
                            activityViewControler.completionWithItemsHandler!(nil, false, nil, nil)

                            expect(analyticsService.lastCustomEventName).to(equal("Cancelled Share"))
                            let expectedAttributes = [
                                AnalyticsServiceConstants.contentIDKey: video.identifier,
                                AnalyticsServiceConstants.contentNameKey: video.title,
                                AnalyticsServiceConstants.contentTypeKey: "Video"
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
                            expect(analyticsService.lastErrorContext).to(equal("Failed to share Video"))
                        }
                    }
                }
            }
        }
    }
}

private class VideoFakeTheme: FakeTheme {
    override func contentBackgroundColor() -> UIColor { return UIColor.magentaColor() }
    override func videoDateFont() -> UIFont { return UIFont.systemFontOfSize(111) }
    override func videoDateColor() -> UIColor { return UIColor.redColor() }
    override func videoTitleFont() -> UIFont  { return UIFont.systemFontOfSize(222) }
    override func videoTitleColor() -> UIColor { return UIColor.blueColor() }
    override func videoDescriptionFont() -> UIFont  { return UIFont.systemFontOfSize(333) }
    override func videoDescriptionColor() -> UIColor { return UIColor.greenColor() }
    override func attributionFont() -> UIFont { return UIFont.systemFontOfSize(444) }
    override func attributionTextColor() -> UIColor { return UIColor.orangeColor() }

    override func attributionButtonBackgroundColor() -> UIColor { return UIColor.brownColor() }
    override func defaultButtonTextColor() -> UIColor { return UIColor.lightGrayColor() }
    override func defaultButtonFont() -> UIFont { return UIFont.systemFontOfSize(555) }
    override func defaultButtonBorderColor() -> UIColor { return UIColor.magentaColor() }
}

private class VideoFakeURLProvider: FakeURLProvider {
    var lastReturnedURL: NSURL!
    var lastIdentifier: String!

    override func youtubeVideoURL(identifier: String) -> NSURL {
        lastIdentifier = identifier
        let urlString = "https://example.com/".stringByAppendingString(identifier)
        lastReturnedURL = NSURL(string: urlString)!
        return lastReturnedURL
    }
}
