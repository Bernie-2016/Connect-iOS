import Foundation
import berniesanders

class FakeTermsAndConditionsAgreementRepository: TermsAndConditionsAgreementRepository {
    var hasReceivedQueryForTermsAgreement = false
    var lastCompletionHandler: ((Bool) -> Void)!
    
    func termsAndConditionsAgreed(completion: (Bool) -> Void) {
        self.hasReceivedQueryForTermsAgreement = true
        self.lastCompletionHandler = completion
    }
    
    var hasAgreedToTerms = false
    
    func userAgreedToTerms(completion:(Void) -> Void) {
        hasAgreedToTerms = true
        completion()
    }
}
