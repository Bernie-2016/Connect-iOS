import berniesanders
import Quick
import Nimble
import UIKit

class TabBarFakeTheme : FakeTheme {
    override func tabBarTintColor() -> UIColor {
        return UIColor.brownColor()
    }
}

class TabBarControllerSpec : QuickSpec {
    var subject: TabBarController!
    
    override func spec() {
        beforeEach {
            let theme = TabBarFakeTheme()
            self.subject = TabBarController(theme: theme, viewControllers: [])
        }
        
        describe("when the controller loads the view") {
            beforeEach {
                self.subject.view.layoutIfNeeded()
            }
            
            it("styles the tab bar with the theme") {
                expect(self.subject.tabBar.barTintColor).to(equal(UIColor.brownColor()))
            }
        }
    }
}