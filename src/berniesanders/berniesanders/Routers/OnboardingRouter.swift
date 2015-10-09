import UIKit

public class OnboardingRouter {
    let applicationSettingsRepository: ApplicationSettingsRepository
    let onboardingController: UIViewController
    let postOnboardingController: UIViewController
    
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
