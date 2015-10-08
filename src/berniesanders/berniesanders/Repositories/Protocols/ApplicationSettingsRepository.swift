import Foundation


public protocol ApplicationSettingsRepository {
    func termsAndConditionsAgreed(completion:(Bool) -> Void)
    func userAgreedToTerms(completion:(Void) -> Void)
}