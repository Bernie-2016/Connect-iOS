import UIKit
import Quick
import Nimble
import berniesanders


class OrganizeFakeTheme : FakeTheme {
    override func tabBarTextColor() -> UIColor {
        return UIColor.purpleColor()
    }
    
    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
}

class OrganizeFakeURLProvider : FakeURLProvider {
    override func bernieCrowdURL() -> NSURL! {
        return NSURL(string: "http://example.com/crowd")
    }
}

class OrganizeControllerSpec : QuickSpec {
    var subject : OrganizeController!
    
    override func spec() {
        beforeEach {
            self.subject = OrganizeController(
                urlProvider: OrganizeFakeURLProvider(),
                theme: OrganizeFakeTheme()
            )
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("Organize"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("Organize"))
        }
        
        it("styles its tab bar item from the theme") {
            let normalAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Normal)
            
            let normalTextColor = normalAttributes[NSForegroundColorAttributeName] as! UIColor
            let normalFont = normalAttributes[NSFontAttributeName] as! UIFont
            
            expect(normalTextColor).to(equal(UIColor.purpleColor()))
            expect(normalFont).to(equal(UIFont.systemFontOfSize(123)))
            
            let selectedAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Selected)
            
            let selectedTextColor = selectedAttributes[NSForegroundColorAttributeName] as! UIColor
            let selectedFont = selectedAttributes[NSFontAttributeName] as! UIFont
            
            expect(selectedTextColor).to(equal(UIColor.purpleColor()))
            expect(selectedFont).to(equal(UIFont.systemFontOfSize(123)))
        }
        
        context("When the view loads") {
            beforeEach {
                self.subject.view.layoutSubviews()
            }
            
            it("should add the webview as a subview") {
                var subviews = self.subject.view.subviews as! [UIView]

                expect(contains(subviews, self.subject.webView)).to(beTrue())
            }
            
            it("should load the BernieCrowd.org checklist into a webview") {
                expect(self.subject.webView.request!.URL).to(equal(NSURL(string: "http://example.com/crowd")))
            }
        }
    }
}
