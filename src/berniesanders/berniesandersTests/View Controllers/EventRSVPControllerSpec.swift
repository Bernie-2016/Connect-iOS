import UIKit
import Quick
import Nimble
@testable import berniesanders


class EventRSVPFakeTheme : FakeTheme {
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.greenColor()
    }

    override func defaultSpinnerColor() -> UIColor {
        return UIColor.redColor()
    }
}

class EventRSVPControllerSpec : QuickSpec {
    var subject : EventRSVPController!
    let event = TestUtils.eventWithName("some event")
    var analyticsService: FakeAnalyticsService!

    override func spec() {
        describe("EventRSVPController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()

                self.subject = EventRSVPController(
                    event: self.event,
                    analyticsService: self.analyticsService,
                    theme: EventRSVPFakeTheme()
                )
            }

            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }


                it("tracks taps on the back button with the analytics service") {
                    self.subject.didMoveToParentViewController(nil)

                    expect(self.analyticsService.lastBackButtonTapScreen).to(equal("Event RSVP"))
                    let expectedAttributes = [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString]
                    expect(self.analyticsService.lastBackButtonTapAttributes! as? [String: String]).to(equal(expectedAttributes))
                }


                it("has the correct navigation item title") {
                    expect(self.subject.navigationItem.title).to(equal("RSVP to Event"))
                }

                it("should add the webview as a subview") {
                    let subviews = self.subject.view.subviews

                    expect(subviews.contains(self.subject.webView)).to(beTrue())
                    expect(subviews.contains(self.subject.loadingIndicatorView)).to(beTrue())
                }

                it("should load the BernieCrowd.org checklist into a webview") {
                    let expectedURL = NSURL(string: "https://example.com#rsvp_container")
                    expect(self.subject.webView.request!.URL).to(equal(expectedURL))
                }

                it("should not show the loading indicator when it's not animating") {
                    expect(self.subject.loadingIndicatorView.hidesWhenStopped).to(beTrue())
                }

                it("styles the view from the theme") {
                    expect(self.subject.view.backgroundColor).to(equal(UIColor.greenColor()))
                }

                it("styles the spinner from the theme") {
                    expect(self.subject.loadingIndicatorView.color).to(equal(UIColor.redColor()))
                }

                context("When the webview starts to load") {
                    it("starts the spinner") {
                        self.subject.webView.delegate!.webViewDidStartLoad!(self.subject.webView)
                        expect(self.subject.loadingIndicatorView.isAnimating()).to(beTrue())
                    }

                    context("and then the webview finishes loading") {
                        it("stops the spinner") {
                            self.subject.webView.delegate!.webViewDidFinishLoad!(self.subject.webView)
                            expect(self.subject.loadingIndicatorView.isAnimating()).to(beFalse())
                        }
                    }
                }
            }
        }
    }
}
