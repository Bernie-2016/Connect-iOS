import UIKit
import Quick
import Nimble
import berniesanders


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
    
    override func spec() {
        describe("EventRSVPController") {
            beforeEach {
                self.subject = EventRSVPController(
                    event: self.event,
                    theme: EventRSVPFakeTheme()
                )
            }
            
            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("has the correct navigation item title") {
                    expect(self.subject.navigationItem.title).to(equal("RSVP to Event"))
                }
                
                it("should add the webview as a subview") {
                    var subviews = self.subject.view.subviews as! [UIView]
                    
                    expect(contains(subviews, self.subject.webView)).to(beTrue())
                    expect(contains(subviews, self.subject.loadingIndicatorView)).to(beTrue())
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
