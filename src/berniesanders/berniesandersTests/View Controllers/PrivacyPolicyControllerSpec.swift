import UIKit
import Quick
import Nimble
import berniesanders


class PrivacyPolicyFakeURLProvider : FakeURLProvider {
    override func privacyPolicyURL() -> NSURL! {
        return NSURL(string: "http://example.com/privates")
    }
}

class PrivacyPolicyControllerSpec : QuickSpec {
    var subject : PrivacyPolicyController!

    override func spec() {
        describe("PrivacyPolicyController") {
            beforeEach {
                self.subject = PrivacyPolicyController(urlProvider: PrivacyPolicyFakeURLProvider())
            }
            
            it("has the correct title") {
                expect(self.subject.title).to(equal("Privacy Policy"))
            }
            
            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("should add the webview as a subview") {
                    var subviews = self.subject.view.subviews as! [UIView]
                    
                    expect(contains(subviews, self.subject.webView)).to(beTrue())
                }
                
                it("should load the iubenda privacy policy page into a webview") {
                    expect(self.subject.webView.request!.URL).to(equal(NSURL(string: "http://example.com/privates")))
                }
            }
        }
    }
}
