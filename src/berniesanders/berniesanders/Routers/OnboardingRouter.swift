import UIKit

public class OnboardingRouter {
    let termsAndConditionsAgreementRepository: TermsAndConditionsAgreementRepository!
    let onboardingController: UIViewController!
    let postOnboardingController: UIViewController!
    
    public init(
        termsAndConditionsAgreementRepository: TermsAndConditionsAgreementRepository,
        onboardingController: UIViewController,
        postOnboardingController: UIViewController) {
            self.termsAndConditionsAgreementRepository = termsAndConditionsAgreementRepository
            self.onboardingController = onboardingController
            self.postOnboardingController = postOnboardingController
    }
    
    public func initialViewController(completion: (UIViewController) -> Void) {
        termsAndConditionsAgreementRepository.termsAndConditionsAgreed { (termsHaveBeenAgreed) -> Void in
            completion(termsHaveBeenAgreed ? self.postOnboardingController : self.onboardingController)
        }
    }
    
    public func controllerDidFinishOnboarding(controller: UIViewController) {
        controller.presentViewController(self.postOnboardingController, animated: true, completion: nil)
    }
}
