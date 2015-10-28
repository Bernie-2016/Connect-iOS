@testable import berniesanders
import Quick
import Nimble
import UIKit

class NavBarFakeTheme : FakeTheme {
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.greenColor()
    }

    override func navigationBarBackgroundColor() -> UIColor {
        return UIColor.brownColor()
    }

    override func navigationBarFont() -> UIFont {
        return UIFont.systemFontOfSize(666)
    }

    override func navigationBarTextColor() -> UIColor {
        return UIColor.magentaColor()
    }
}

class NavigationControllerSpec : QuickSpec {
    var subject: NavigationController!

    override func spec() {
        beforeEach {
            let theme = NavBarFakeTheme()
            self.subject = NavigationController(theme: theme)
        }

        describe("when the controller loads the view") {
            beforeEach {
                self.subject.view.layoutIfNeeded()
            }

            it("sets the navigation bar to be opaque") {
                expect(self.subject.navigationBar.translucent).to(beFalse())
            }

            it("styles the navigation bar with the theme") {
                let attributes = self.subject.navigationBar.titleTextAttributes!
                let textColor = attributes[NSForegroundColorAttributeName] as! UIColor
                let font = attributes[NSFontAttributeName] as! UIFont

                                expect(self.subject.navigationBar.barTintColor).to(equal(UIColor.brownColor()))
                expect(textColor).to(equal(UIColor.magentaColor()))
                expect(font).to(equal(UIFont.systemFontOfSize(666)))
                expect(self.subject.view.backgroundColor).to(equal(UIColor.greenColor()))
            }
        }
    }
}
