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
    var analyticsService : FakeAnalyticsService!
    var controllerA : UIViewController!
    var controllerB : UIViewController!
    
    override func spec() {
        describe("TabBarController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()
                self.controllerA = UIViewController()
                self.controllerA.tabBarItem.title = "Controller A"
                self.controllerB = UIViewController()
                self.controllerB.tabBarItem.title = "Controller B"
                
                let theme = TabBarFakeTheme()
                
                self.subject = TabBarController(
                    viewControllers: [self.controllerA, self.controllerB],
                    analyticsService: self.analyticsService,
                    theme: theme)
            }
            
            describe("when the controller loads the view") {
                beforeEach {
                    self.subject.view.layoutIfNeeded()
                }
                
                it("styles the tab bar with the theme") {
                    expect(self.subject.tabBar.barTintColor).to(equal(UIColor.brownColor()))
                }
            }
            
            describe("tapping on a tab bar item") {
                it("tracks that tap via analytics") {
                    self.subject.tapTabAtIndex(0)
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped \"Controller A\" on tab bar"))
                    expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                    
                    self.subject.tapTabAtIndex(1)
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped \"Controller B\" on tab bar"))
                    expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                }
            }
        }
    }
}