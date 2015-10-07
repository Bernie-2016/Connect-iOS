import Foundation

public class ConcreteTermsAndConditionsAgreementRepository: TermsAndConditionsAgreementRepository {
    private let userDefaults: NSUserDefaults
    
    private let kUserAgreedToTermsKey = "kUserAgreedToTermsKey"
    
    public init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public func termsAndConditionsAgreed(completion: (Bool) -> Void) {
        let userAgreedToTermsOnDate: AnyObject? = self.userDefaults.objectForKey(kUserAgreedToTermsKey)
        
        completion(userAgreedToTermsOnDate != nil)
    }
    
    public func userAgreedToTerms(completion: (Void) -> Void) {
        self.userDefaults.setObject(NSDate(), forKey: kUserAgreedToTermsKey)
        completion()
    }
}

