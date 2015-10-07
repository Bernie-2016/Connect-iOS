import Foundation


public protocol TermsAndConditionsAgreementRepository {
    func termsAndConditionsAgreed(completion:(Bool) -> Void)
    func userAgreedToTerms(completion:(Void) -> Void)
}