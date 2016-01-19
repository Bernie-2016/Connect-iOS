import Foundation
import Quick
import Nimble
@testable import Movement

class WelcomeFakeTheme: FakeTheme {
    override func defaultButtonBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func defaultBackgroundColor() -> UIColor { return UIColor.greenColor() }
    override func defaultButtonFont() -> UIFont { return UIFont.italicSystemFontOfSize(222) }
    override func defaultButtonTextColor() -> UIColor { return UIColor.yellowColor() }
    override func welcomeTakeThePowerBackFont() -> UIFont { return UIFont.italicSystemFontOfSize(111) }
    override func viewPolicyBackgroundColor() -> UIColor { return UIColor.magentaColor() }
    override func agreeToTermsLabelFont() -> UIFont { return UIFont.italicSystemFontOfSize(333) }
    override func welcomeBackgroundColor() -> UIColor { return UIColor.redColor() }
    override func welcomeTextColor() -> UIColor { return UIColor.purpleColor() }
}

class FakeOnboardingWorkflow: OnboardingWorkflow {
    var hasFinishedOnboarding = false
    var lastControllerToFinishOnboarding: UIViewController!

    init() {
        super.init(
            applicationSettingsRepository: FakeApplicationSettingsRepository(),
            onboardingController: UIViewController(),
            postOnboardingController: UIViewController(),
            pushNotificationRegistrar: FakePushNotificationRegistrar(),
            application: FakeApplication()
        )
    }

    var lastInitialViewControllerCompletionHandler: ((UIViewController) -> Void)!
    override func initialViewController(completion: (UIViewController) -> Void) {
        lastInitialViewControllerCompletionHandler = completion
    }

    override internal func controllerDidFinishOnboarding(controller: UIViewController) {
        hasFinishedOnboarding = true
        lastControllerToFinishOnboarding = controller
    }
}

class WelcomeControllerSpec: QuickSpec {
    var subject: WelcomeController!
    var onboardingWorkflow: FakeOnboardingWorkflow!
    var applicationSettingsRepository: FakeApplicationSettingsRepository!
    let termsAndConditionsController = TestUtils.termsAndConditionsController()
    let privacyPolicyController = TestUtils.privacyPolicyController()
    var analyticsService: FakeAnalyticsService!
    let theme = WelcomeFakeTheme()

    var navigationController: UINavigationController!

    override func spec() {
        describe("WelcomeController") {
            beforeEach {
                self.applicationSettingsRepository = FakeApplicationSettingsRepository()
                self.analyticsService = FakeAnalyticsService()
                self.onboardingWorkflow = FakeOnboardingWorkflow()

                self.subject = WelcomeController(
                    applicationSettingsRepository: self.applicationSettingsRepository,
                    termsAndConditionsController: self.termsAndConditionsController,
                    privacyPolicyController: self.privacyPolicyController,
                    analyticsService: self.analyticsService,
                    theme: self.theme
                )

                self.subject.onboardingWorkflow = self.onboardingWorkflow

                self.navigationController = UINavigationController()
                self.navigationController.pushViewController(self.subject, animated: false)
            }

            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }

                it("has a scroll view containing the UI elements") {
                    expect(self.subject.view.subviews.count).to(equal(4))

                    let subviews = self.subject.view.subviews

                    expect(subviews.contains(self.subject.billionairesImageView)).to(beTrue())
                    expect(subviews.contains(self.subject.takeThePowerBackLabel)).to(beTrue())
                    expect(subviews.contains(self.subject.agreeToTermsNoticeTextView)).to(beTrue())
                    expect(subviews.contains(self.subject.agreeToTermsButton)).to(beTrue())
                }

                it("enables analytics") {
                    expect(self.applicationSettingsRepository.lastAnalyticsPermissionGrantedValue).to(beTrue())
                }

                it("has the correct image in the banner image view") {
                    expect(self.subject.billionairesImageView.image).to(equal(UIImage(named: "billionaires")))
                }

                it("has a label with some welcome text") {
                    expect(self.subject.takeThePowerBackLabel.text).to(contain("take our country back"))
                }

                xdescribe("tapping on the view privacy policy text") {
                    beforeEach {
                        // TODO: figure out a way to test this.
                    }

                    it("should push a correctly configured news item view controller onto the nav stack") {
                        expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.privacyPolicyController))
                    }

                    it("should log a content view with the analytics service") {
                        expect(self.analyticsService.lastContentViewName).to(equal("Privacy Policy"))
                        expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Onboarding))
                        expect(self.analyticsService.lastContentViewID).to(equal("Privacy Policy"))
                    }
                }

                xdescribe("tapping on the view terms text") {
                    beforeEach {
                        // TODO: figure out a way to test this.
                    }

                    it("should push a correctly configured news item view controller onto the nav stack") {
                        expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.termsAndConditionsController))
                    }

                    it("should log a content view with the analytics service") {
                        expect(self.analyticsService.lastContentViewName).to(equal("Terms and Conditions"))
                        expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Onboarding))
                        expect(self.analyticsService.lastContentViewID).to(equal("Terms and Conditions"))
                    }
                }

                it("has a label informing the user to agree to the terms to continue") {
                    expect(self.subject.agreeToTermsNoticeTextView.text).to(equal("By tapping Continue, you are agreeing to the Terms and Conditions and Privacy Policy. This app is not affiliated with or authorized by Bernie 2016."))
                }

                it("has a button for agreeing to the terms and conditions") {
                    expect(self.subject.agreeToTermsButton.titleForState(.Normal)).to((equal("CONTINUE")))
                }

                describe("tapping on the agree to terms button") {
                    beforeEach {
                        self.subject.agreeToTermsButton.tap()
                    }

                    it("opens tells the terms agreement repository that the user agreed to terms") {
                        expect(self.applicationSettingsRepository.hasAgreedToTerms).to(beTrue())
                    }

                    it("logs that the user tapped the coders button") {
                        expect(self.analyticsService.lastCustomEventName).to(equal("User agreed to Terms and Conditions"))
                        expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                    }

                    context("when the terms agreement repository confirms that the user agreed to terms") {
                        it("tells the onboarding router that the user finished onboarding") {
                            expect(self.onboardingWorkflow.hasFinishedOnboarding).to(beTrue())
                            expect(self.onboardingWorkflow.lastControllerToFinishOnboarding).to(beIdenticalTo(self.subject))
                        }
                    }
                }

                describe("when the view appears") {
                    beforeEach {
                        self.subject.viewWillAppear(false)
                    }

                    it("hides the navigation bar") {
                        expect(self.subject.navigationController!.navigationBarHidden).to(beTrue())
                    }
                }

                it("styles the view components with the theme") {
                    expect(self.subject.view.backgroundColor).to(equal(UIColor.redColor()))

                    expect(self.subject.takeThePowerBackLabel.font).to(equal(UIFont.italicSystemFontOfSize(111)))
                    expect(self.subject.takeThePowerBackLabel.textColor).to(equal(UIColor.purpleColor()))

                    expect(self.subject.agreeToTermsNoticeTextView.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                    expect(self.subject.agreeToTermsNoticeTextView.textColor).to(equal(UIColor.purpleColor()))
                    expect(self.subject.agreeToTermsNoticeTextView.backgroundColor).to(equal(UIColor.redColor()))

                    expect(self.subject.agreeToTermsButton.backgroundColor).to(equal(UIColor.orangeColor()))
                    expect(self.subject.agreeToTermsButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(self.subject.agreeToTermsButton.titleColorForState(.Normal)).to(equal(UIColor.yellowColor()))
                }
            }
        }
    }
}
