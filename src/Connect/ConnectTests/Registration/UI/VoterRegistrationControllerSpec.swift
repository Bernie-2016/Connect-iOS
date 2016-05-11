import Quick
import Nimble

@testable import Connect

class VoterRegistrationControllerSpec: QuickSpec {
    override func spec() {
        describe("VoterRegistrationController") {
            var subject: VoterRegistrationController!
            var tabBarItemStylist: FakeTabBarItemStylist!

            beforeEach {
                tabBarItemStylist = FakeTabBarItemStylist()

                subject = VoterRegistrationController(
                    tabBarItemStylist: tabBarItemStylist
                )
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(tabBarItemStylist.lastReceivedTabBarItem) === subject.tabBarItem

                expect(tabBarItemStylist.lastReceivedTabBarImage) == UIImage(named: "registerTabBarIconInactive")
                expect(tabBarItemStylist.lastReceivedTabBarSelectedImage) == UIImage(named: "registerTabBarIcon")
            }
        }
    }
}
