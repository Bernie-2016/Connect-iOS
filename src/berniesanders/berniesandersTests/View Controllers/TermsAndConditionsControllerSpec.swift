import Foundation
import Quick
import Nimble
import berniesanders

class TermsAndConditionsControllerSpec : QuickSpec {
    var subject : TermsAndConditionsController!
    var analyticsService: FakeAnalyticsService!
    let navigationController = UINavigationController()

    override func spec() {
        describe("TermsAndConditionsController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()

                self.subject = TermsAndConditionsController(analyticsService: self.analyticsService)

                self.navigationController.setNavigationBarHidden(true, animated: false)
                self.navigationController.pushViewController(self.subject, animated: false)
            }

            it("has the correct title") {
                expect(self.subject.title).to(equal("Terms and Conditions"))
            }


            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }

                it("tracks taps on the back button with the analytics service") {
                    self.subject.didMoveToParentViewController(nil)

                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Back' on Terms and Conditions"))
                    expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                }

                it("should add the webview as a subview") {
                    let subviews = self.subject.view.subviews

                    expect(subviews.contains(self.subject.webView)).to(beTrue())
                }

                it("should load bundled TermsAndConditions page into a webview") {
                    let filePath = NSBundle.mainBundle().pathForResource("terms_and_conditions", ofType: "html")
                    let fileURL = NSURL(fileURLWithPath: filePath!)

                    expect(self.subject.webView.request!.URL).to(equal(fileURL))
                }

                describe("when the view appears") {
                    beforeEach {
                        self.subject.viewWillAppear(false)
                    }

                    it("ensures that the navigation bar is visible") {
                        expect(self.subject.navigationController!.navigationBarHidden).to(beFalse())
                    }
                }
            }
        }
    }
}
