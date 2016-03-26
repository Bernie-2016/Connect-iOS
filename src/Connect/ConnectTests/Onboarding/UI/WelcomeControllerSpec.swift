import Foundation
import Quick
import Nimble
@testable import Connect

class WelcomeFakeTheme: FakeTheme {
    override func defaultButtonBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func defaultBackgroundColor() -> UIColor { return UIColor.greenColor() }
    override func defaultButtonFont() -> UIFont { return UIFont.italicSystemFontOfSize(222) }
    override func defaultButtonTextColor() -> UIColor { return UIColor.yellowColor() }
    override func welcomeTakeThePowerBackFont() -> UIFont { return UIFont.italicSystemFontOfSize(111) }
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
    override func spec() {
        describe("WelcomeController") {
            var subject: WelcomeController!
            var onboardingWorkflow: FakeOnboardingWorkflow!
            var applicationSettingsRepository: FakeApplicationSettingsRepository!
            let privacyPolicyController = TestUtils.privacyPolicyController()
            var analyticsService: FakeAnalyticsService!
            let theme = WelcomeFakeTheme()

            var navigationController: UINavigationController!
            beforeEach {
                applicationSettingsRepository = FakeApplicationSettingsRepository()
                analyticsService = FakeAnalyticsService()
                onboardingWorkflow = FakeOnboardingWorkflow()

                subject = WelcomeController(
                    applicationSettingsRepository: applicationSettingsRepository,
                    privacyPolicyController: privacyPolicyController,
                    analyticsService: analyticsService,
                    theme: theme
                )

                subject.onboardingWorkflow = onboardingWorkflow

                navigationController = UINavigationController()
                navigationController.pushViewController(subject, animated: false)
            }

            context("When the view loads") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("has a scroll view containing the UI elements") {
                    expect(subject.view.subviews.count) == 3

                    let subviews = subject.view.subviews

                    expect(subviews.contains(subject.actionAlertImageView)) == true
                    expect(subviews.contains(subject.takeThePowerBackLabel)) == true
                    expect(subviews.contains(subject.continueButton)) == true
                }

                it("enables analytics") {
                    expect(applicationSettingsRepository.lastAnalyticsPermissionGrantedValue) == true
                }

                it("has the correct image in the banner image view") {
                    expect(subject.actionAlertImageView.image) == UIImage(named: "actionAlertExample")
                }

                it("has a label with some welcome text") {
                    expect(subject.takeThePowerBackLabel.text).to(contain("Political Revolution"))
                }

                it("has a button to advance to the next screen") {
                    expect(subject.continueButton.titleForState(.Normal)) == "GET STARTED"
                }

                describe("tapping on the continue button") {
                    beforeEach {
                        subject.continueButton.tap()
                    }

                    it("opens tells the terms agreement repository that the user agreed to terms") {
                        expect(applicationSettingsRepository.hasAgreedToTerms) == true
                    }

                    it("logs that the user tapped the continue button") {
                        expect(analyticsService.lastCustomEventName) == "User tapped continue on welcome screen"
                        expect(analyticsService.lastCustomEventAttributes).to(beNil())
                    }

                    context("when the terms agreement repository confirms that the user agreed to terms") {
                        it("tells the onboarding router that the user finished onboarding") {
                            expect(onboardingWorkflow.hasFinishedOnboarding) == true
                            expect(onboardingWorkflow.lastControllerToFinishOnboarding) === subject
                        }
                    }
                }

                describe("when the view appears") {
                    beforeEach {
                        subject.viewWillAppear(false)
                    }

                    it("hides the navigation bar") {
                        expect(subject.navigationController!.navigationBarHidden) == true
                    }
                }

                it("styles the view components with the theme") {
                    expect(subject.view.backgroundColor) == UIColor.redColor()

                    expect(subject.takeThePowerBackLabel.font) == UIFont.italicSystemFontOfSize(111)
                    expect(subject.takeThePowerBackLabel.textColor) == UIColor.purpleColor()

                    expect(subject.continueButton.backgroundColor) == UIColor.orangeColor()
                    expect(subject.continueButton.titleLabel!.font) == UIFont.italicSystemFontOfSize(222)
                    expect(subject.continueButton.titleColorForState(.Normal)) == UIColor.yellowColor()
                }
            }
        }
    }
}
