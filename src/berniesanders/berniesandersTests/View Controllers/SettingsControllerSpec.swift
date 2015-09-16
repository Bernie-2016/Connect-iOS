import UIKit
import Quick
import Nimble
import berniesanders

class SettingsFakeTheme : FakeTheme {
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }
}


class SettingsControllerSpec : QuickSpec {
    var subject: SettingsController!
    let theme = SettingsFakeTheme()
    
    override func spec() {
        describe("SettingsController") {
            beforeEach {
                self.subject = SettingsController(theme: self.theme)
            }
            
            it("should hide the tab bar when pushed") {
                expect(self.subject.hidesBottomBarWhenPushed).to(beTrue())
            }
            
            it("has the correct navigation item title") {
                expect(self.subject.navigationItem.title).to(equal("Settings"))
            }
            
            describe("when the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("styles the views according to the theme") {
                    expect(self.subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                }
            }
        }
    }
}
