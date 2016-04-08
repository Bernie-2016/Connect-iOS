import Foundation
import Quick
import Nimble
@testable import Connect

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

                it("has the UI elements") {
                    expect(subject.view.subviews.count) == 3

                    let subviews = subject.view.subviews

                    expect(subviews.contains(subject.backgroundImageView)) == true
                    expect(subviews.contains(subject.scrollView)) == true
                    expect(subviews.contains(subject.continueButton)) == true

                    let containerView = subject.scrollView.subviews.first!

                    expect(containerView.subviews).to(contain(subject.welcomeHeaderLabel))
                    expect(containerView.subviews).to(contain(subject.welcomeMessageLabel))
                }

                it("has the correct background image") {
                        let backgroundImageView = subject.backgroundImageView
                        expect(backgroundImageView.image) == UIImage(named: "gradientBackground")
                }

                it("enables analytics") {
                    expect(applicationSettingsRepository.lastAnalyticsPermissionGrantedValue) == true
                }

                it("has a label with a header text") {
                    expect(subject.welcomeHeaderLabel.text).to(contain("Welcome"))
                }

                it("has a label with the welcome message") {
                    expect(subject.welcomeMessageLabel.text).to(contain("Connect with Bernie is designed"))
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

                    expect(subject.welcomeHeaderLabel.font) == UIFont.italicSystemFontOfSize(111)
                    expect(subject.welcomeHeaderLabel.textColor) == UIColor.purpleColor()
                    expect(subject.welcomeMessageLabel.font) == UIFont.italicSystemFontOfSize(333)
                    expect(subject.welcomeMessageLabel.textColor) == UIColor.purpleColor()

                    expect(subject.continueButton.backgroundColor) == UIColor.orangeColor()
                    expect(subject.continueButton.titleLabel!.font) == UIFont.italicSystemFontOfSize(222)
                    expect(subject.continueButton.titleColorForState(.Normal)) == UIColor.yellowColor()
                }
            }
        }
    }
}

class WelcomeFakeTheme: FakeTheme {
    override func welcomeButtonBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func welcomeButtonTextColor() -> UIColor { return UIColor.yellowColor() }
    override func defaultButtonFont() -> UIFont { return UIFont.italicSystemFontOfSize(222) }

    override func defaultBackgroundColor() -> UIColor { return UIColor.greenColor() }

    override func welcomeHeaderFont() -> UIFont { return UIFont.italicSystemFontOfSize(111) }
    override func welcomeBackgroundColor() -> UIColor { return UIColor.redColor() }
    override func welcomeTextColor() -> UIColor { return UIColor.purpleColor() }
    override func welcomeMessageFont() -> UIFont { return UIFont.italicSystemFontOfSize(333) }
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
