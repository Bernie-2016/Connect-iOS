import Quick
import Nimble


@testable import Connect

class FakeTabBarItemTheme: FakeTheme {
    override func tabBarActiveTextColor() -> UIColor {
        return UIColor.purpleColor()
    }

    override func tabBarInactiveTextColor() -> UIColor {
        return UIColor.redColor()
    }

    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
}

class ConcreteTabBarItemStylistSpec: QuickSpec {
    var subject: ConcreteTabBarItemStylist!
    var tabBarItem: UITabBarItem!

    override func spec() {
        describe("ConcreteTabBarItemStylist") {
            beforeEach {
                self.tabBarItem = UITabBarItem()
                self.subject = ConcreteTabBarItemStylist(theme: FakeTabBarItemTheme())
            }

            describe("styling a tab bar item") {
                let image = UIImage(named: "newsTabBarIcon")!
                let selectedImage = UIImage(named: "issuesTabBarIcon")!

                beforeEach {
                    self.subject.applyThemeToBarBarItem(self.tabBarItem, image: image, selectedImage: selectedImage)
                }

                it("styles its tab bar item from the theme") {
                    let normalAttributes = self.tabBarItem.titleTextAttributesForState(UIControlState.Normal)

                    let normalTextColor = normalAttributes?[NSForegroundColorAttributeName] as! UIColor
                    let normalFont = normalAttributes?[NSFontAttributeName] as! UIFont

                    expect(normalTextColor).to(equal(UIColor.redColor()))
                    expect(normalFont).to(equal(UIFont.systemFontOfSize(123)))

                    let selectedAttributes = self.tabBarItem.titleTextAttributesForState(UIControlState.Selected)

                    let selectedTextColor = selectedAttributes?[NSForegroundColorAttributeName] as! UIColor
                    let selectedFont = selectedAttributes?[NSFontAttributeName] as! UIFont

                    expect(selectedTextColor).to(equal(UIColor.purpleColor()))
                    expect(selectedFont).to(equal(UIFont.systemFontOfSize(123)))
                }

                it("sets up the image and selected image") {
                    let expectedImageData = UIImagePNGRepresentation(image)
                    let expectedSelectedImageData = UIImagePNGRepresentation(selectedImage)

                    expect(UIImagePNGRepresentation(self.tabBarItem.image!)).to(equal(expectedImageData))
                    expect(UIImagePNGRepresentation(self.tabBarItem.selectedImage!)).to(equal(expectedSelectedImageData))
                }
            }
        }
    }
}
