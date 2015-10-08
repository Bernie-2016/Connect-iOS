import Quick
import Nimble
import berniesanders

class DonateFakeURLProvider : FakeURLProvider {
    override func donateFormURL() -> NSURL! {
        return NSURL(string: "http://example.com/donate")
    }
}

class DonateControllerSpec: QuickSpec {
    var subject: DonateController!
    var analyticsService: FakeAnalyticsService!

    override func spec() {
        describe("DonateController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()
                
                self.subject = DonateController(
                    urlProvider: DonateFakeURLProvider(),
                    analyticsService: self.analyticsService
                )
            }
            
            it("has the correct title") {
                expect(self.subject.title).to(equal("Donate"))
            }

            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("tracks taps on the back button with the analytics service") {
                    self.subject.didMoveToParentViewController(nil)
                    
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Back' on Donate"))
                    expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                }
                
                it("should add the webview as a subview") {
                    var subviews = self.subject.view.subviews as! [UIView]
                    
                    expect(contains(subviews, self.subject.webView)).to(beTrue())
                }
                
                it("should load the iubenda privacy policy page into a webview") {
                    expect(self.subject.webView.request!.URL).to(equal(NSURL(string: "http://example.com/donate")))
                }
            }
        }
    }
}
