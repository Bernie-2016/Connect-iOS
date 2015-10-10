import UIKit

public class OnboardingRouter {
    private let applicationSettingsRepository: ApplicationSettingsRepository
    private let onboardingController: UIViewController
    private let postOnboardingController: UIViewController

    public init(
        applicationSettingsRepository: ApplicationSettingsRepository,
        onboardingController: UIViewController,
        postOnboardingController: UIViewController) {
            self.applicationSettingsRepository = applicationSettingsRepository
            self.onboardingController = onboardingController
            self.postOnboardingController = postOnboardingController
    }

    public func initialViewController(completion: (UIViewController) -> Void) {
        applicationSettingsRepository.termsAndConditionsAgreed { (termsHaveBeenAgreed) -> Void in
            completion(termsHaveBeenAgreed ? self.postOnboardingController : self.onboardingController)
        }
    }

    public func controllerDidFinishOnboarding(controller: UIViewController) {
        controller.presentViewController(self.postOnboardingController, animated: true, completion: nil)
    }
}
