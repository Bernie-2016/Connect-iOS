import UIKit
import Quick
import Nimble
import berniesanders

class SettingsFakeTheme : FakeTheme {
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }
    
    override func settingsTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
    
    override func settingsTitleColor() -> UIColor {
        return UIColor.purpleColor()
    }
}


class SettingsControllerSpec : QuickSpec {
    var subject: SettingsController!
    let theme = SettingsFakeTheme()
    let privacyPolicyController = TestUtils.privacyPolicyController()
    let navigationController = UINavigationController()

    override func spec() {
        describe("SettingsController") {
            beforeEach {
                self.subject = SettingsController(privacyPolicyController: self.privacyPolicyController, theme: self.theme)
                
                self.navigationController.pushViewController(self.subject, animated: false)
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
                
                it("should have one row in the table") {
                    expect(self.subject.tableView.numberOfSections()).to(equal(1))
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(1))
                }
                
                it("should style the rows") {
                    var cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                    
                    expect(cell.textLabel!.textColor).to(equal(UIColor.purpleColor()))
                    expect(cell.textLabel!.font).to(equal(UIFont.systemFontOfSize(123)))
                }
                
                describe("the Privacy Policy row") {
                    it("has a Privacy Policy row") {
                        var cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                        expect(cell.textLabel!.text).to(equal("Privacy Policy"))
                    }
                    
                    describe("tapping the Privacy Policy row") {
                        it("should push a correctly configured news item view controller onto the nav stack") {
                            let tableView = self.subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                            expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.privacyPolicyController))
                        }
                    }
                }
            }
        }
    }
}
