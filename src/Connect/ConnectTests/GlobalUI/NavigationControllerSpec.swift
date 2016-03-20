@testable import Connect
import Quick
import Nimble
import UIKit

class NavBarFakeTheme: FakeTheme {
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

    override func navigationBarButtonFont() -> UIFont {
        return UIFont.systemFontOfSize(42)
    }

    override func navigationBarButtonTextColor() -> UIColor {
        return UIColor.orangeColor()
    }

    override func navigationBarTintColor() -> UIColor {
        return UIColor.blueColor()
    }
}

class NavigationControllerSpec : QuickSpec {
    override func spec() {
        describe("NavigationController") {
            var subject: NavigationController!

            beforeEach {
                let theme = NavBarFakeTheme()
                subject = NavigationController(theme: theme)
            }

            describe("when the controller loads the view") {
                beforeEach {
                    subject.view.layoutIfNeeded()
                }

                it("hides the bar on swipe") {
                    expect(subject.hidesBarsOnSwipe) == true
                }

                it("sets the navigation bar to be opaque") {
                    expect(subject.navigationBar.translucent).to(beFalse())
                }

                it("styles the navigation bar with the theme") {
                    let attributes = subject.navigationBar.titleTextAttributes!
                    let textColor = attributes[NSForegroundColorAttributeName] as! UIColor
                    let font = attributes[NSFontAttributeName] as! UIFont
                    expect(subject.navigationBar.barTintColor) == UIColor.brownColor()
                    expect(subject.navigationBar.tintColor) == UIColor.blueColor()
                    expect(textColor) == UIColor.magentaColor()
                    expect(font) == UIFont.systemFontOfSize(666)
                    expect(subject.view.backgroundColor) == UIColor.greenColor()
                }

                it("styles the bar button item appearance with the theme") {
                    let attributes = UIBarButtonItem.appearance().titleTextAttributesForState(.Normal)!

                    let font = attributes[NSFontAttributeName] as! UIFont
                    let textColor = attributes[NSForegroundColorAttributeName] as! UIColor

                    expect(font) == UIFont.systemFontOfSize(42)
                    expect(textColor) == UIColor.orangeColor()
                }

                it("sets the back button image on the navigation bar") {
                    let expectedImage = UIImage(named: "BackArrow")
                    let actualImage = subject.navigationBar.backIndicatorImage
                    let actualTransitionImage = subject.navigationBar.backIndicatorTransitionMaskImage

                    expect(actualImage) == expectedImage
                    expect(actualTransitionImage) == expectedImage
                }
            }
        }
    }
}
