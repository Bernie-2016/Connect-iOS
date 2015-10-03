import UIKit
import Quick
import Nimble
import berniesanders

class FLOSSControllerSpec : QuickSpec {
    var subject : FLOSSController!
    var analyticsService: FakeAnalyticsService!

    override func spec() {
        describe("FLOSSController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()

                self.subject = FLOSSController(analyticsService: self.analyticsService)
            }
            
            it("has the correct title") {
                expect(self.subject.title).to(equal("Open Source Software"))
            }
            
            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("tracks taps on the back button with the analytics service") {
                    self.subject.didMoveToParentViewController(nil)
                    
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Back' on Open Source Software"))
                }
                
                it("should add the webview as a subview") {
                    var subviews = self.subject.view.subviews as! [UIView]
                    
                    expect(contains(subviews, self.subject.webView)).to(beTrue())
                }
                
                it("should load bundled FLOSS page into a webview") {
                    let filePath = NSBundle.mainBundle().pathForResource("floss_licenses", ofType: "html")
                    let fileURL = NSURL(fileURLWithPath: filePath!)!
                    
                    expect(self.subject.webView.request!.URL).to(equal(fileURL))
                }
            }
        }
    }
}
