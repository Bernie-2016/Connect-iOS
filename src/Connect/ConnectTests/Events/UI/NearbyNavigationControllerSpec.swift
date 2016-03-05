import Quick
import Nimble

@testable import Connect

class NearbyNavigationControllerSpec: QuickSpec {
    override func spec() {
        describe("NearbyNavigationController") {
            var subject: NearbyNavigationController!
            var interstitialController: UIViewController!

            beforeEach {
                interstitialController = UIViewController()

                subject = NearbyNavigationController(
                    interstitialController: interstitialController
                )
            }

            describe("when the view first loads") {
                beforeEach {
                    expect(subject.view).toNot(beNil())
                }

                it("shows the interstitial controller") {
                    expect(subject.topViewController) === interstitialController
                }
            }
        }
    }
}
