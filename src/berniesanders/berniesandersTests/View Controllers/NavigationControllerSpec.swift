import berniesanders
import Quick
import Nimble
import UIKit

class NavBarFakeTheme : FakeTheme {
    override func navigationBarBackgroundColor() -> UIColor {
        return UIColor.brownColor()
    }
    
    override func navigationBarFont() -> UIFont {
        return UIFont.systemFontOfSize(666)
    }

    override func navigationBarTextColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    override func tabBarTextColor() -> UIColor {
        return UIColor.yellowColor()
    }
    
    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
}

class NavigationControllerSpec : QuickSpec {
    var subject: NavigationController!
    
    override func spec() {
        beforeEach {
            let theme = NavBarFakeTheme()
            self.subject = NavigationController(theme: theme)
        }
        
        it("styles its tab bar item from the theme") {
            let normalAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Normal)
            
            let normalTextColor = normalAttributes[NSForegroundColorAttributeName] as! UIColor
            let normalFont = normalAttributes[NSFontAttributeName] as! UIFont
            
            expect(normalTextColor).to(equal(UIColor.yellowColor()))
            expect(normalFont).to(equal(UIFont.systemFontOfSize(123)))
            
            let selectedAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Selected)
            
            let selectedTextColor = selectedAttributes[NSForegroundColorAttributeName] as! UIColor
            let selectedFont = selectedAttributes[NSFontAttributeName] as! UIFont
            
            expect(selectedTextColor).to(equal(UIColor.yellowColor()))
            expect(selectedFont).to(equal(UIFont.systemFontOfSize(123)))
        }
        
        describe("when the controller loads the view") {
            beforeEach {
                self.subject.view.layoutIfNeeded()
            }
            
            it("styles the navigation bar with the theme") {
                let attributes = self.subject.navigationBar.titleTextAttributes!
                let textColor = attributes[NSForegroundColorAttributeName] as! UIColor
                let font = attributes[NSFontAttributeName] as! UIFont

                                expect(self.subject.navigationBar.barTintColor).to(equal(UIColor.brownColor()))
                expect(textColor).to(equal(UIColor.magentaColor()))
                expect(font).to(equal(UIFont.systemFontOfSize(666)))
            }
        }
    }
}