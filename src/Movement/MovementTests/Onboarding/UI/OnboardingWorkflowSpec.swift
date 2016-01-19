import Foundation
import Quick
import Nimble
@testable import Movement


class OnboardingWorkflowSpec: QuickSpec {
    var subject: OnboardingWorkflow!
    var applicationSettingsRepository: FakeApplicationSettingsRepository!
    var pushNotificationRegistrar: FakePushNotificationRegistrar!
    var onboardingController: UIViewController!
    var postOnboardingController: UIViewController!
    let application = FakeApplication()

    override func spec() {
        describe("OnboardingWorkflow") {
            beforeEach {
                self.onboardingController = UIViewController()
                self.postOnboardingController = UIViewController()
                self.applicationSettingsRepository = FakeApplicationSettingsRepository()
                self.pushNotificationRegistrar = FakePushNotificationRegistrar()

                self.subject = OnboardingWorkflow(
                    applicationSettingsRepository: self.applicationSettingsRepository,
                    onboardingController: self.onboardingController,
                    postOnboardingController: self.postOnboardingController,
                    pushNotificationRegistrar: self.pushNotificationRegistrar,
                    application: self.application)
            }

            describe("getting the initial view controller in the workflow") {
                var initialViewController: UIViewController!
                beforeEach {
                    self.subject.initialViewController({ (receivedViewController) -> Void in
                        initialViewController = receivedViewController
                    })
                }

                it("should ask the repository for if the terms and conditions have been agreed to") {
                    expect(self.applicationSettingsRepository.hasReceivedQueryForTermsAgreement).to(beTrue())
                }

                context("when the user has not agreed to the terms and conditions") {
                    beforeEach {
                        self.applicationSettingsRepository.lastTermsAndConditionsCompletionHandler(false)
                    }

                    it("returns the welcome view controller") {
                        expect(initialViewController).to(beIdenticalTo(self.onboardingController))
                    }
                }

                context("when the user has agreed to the terms and conditions") {
                    beforeEach {
                        self.applicationSettingsRepository.lastTermsAndConditionsCompletionHandler(true)
                    }

                    it("tells the push registrar to register for remote notifications") {
                        let lastRegisteredApplication: FakeApplication = self.pushNotificationRegistrar.lastAppUsedForRegistration as! FakeApplication
                        expect(lastRegisteredApplication).to(beIdenticalTo(self.application))
                    }

                    it("returns the post-onboarding view controller") {
                        expect(initialViewController).to(beIdenticalTo(self.postOnboardingController))
                    }
                }
            }

            describe("when a controller notifies the router that the user agreed to terms and conditions") {
                it("presents the post onboarding controller") {
                    self.subject.controllerDidFinishOnboarding(self.onboardingController)

                    expect(self.onboardingController.presentedViewController).to(beIdenticalTo(self.postOnboardingController))
                }

                it("tells the push registrar to register for remote notifications") {
                    self.subject.controllerDidFinishOnboarding(self.onboardingController)

                    let lastRegisteredApplication: FakeApplication = self.pushNotificationRegistrar.lastAppUsedForRegistration as! FakeApplication

                    expect(lastRegisteredApplication).to(beIdenticalTo(self.application))
                }
            }
        }
    }
}
