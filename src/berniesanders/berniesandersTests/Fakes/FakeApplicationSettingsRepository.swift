import Foundation
import berniesanders

class FakeApplicationSettingsRepository: ApplicationSettingsRepository {
    var hasReceivedQueryForTermsAgreement = false
    var lastTermsAndConditionsCompletionHandler: ((Bool) -> Void)!
    
    func termsAndConditionsAgreed(completion: (Bool) -> Void) {
        hasReceivedQueryForTermsAgreement = true
        lastTermsAndConditionsCompletionHandler = completion
    }
    
    var hasAgreedToTerms = false
    
    func userAgreedToTerms(completion:(Void) -> Void) {
        hasAgreedToTerms = true
        completion()
    }

    var hasReceivedQueryForAnalytics = false
    var lastAnalyticsCompletionHandler: ((Bool) -> Void)!

    func isAnalyticsEnabled(completion:(Bool) -> Void) {
        hasReceivedQueryForAnalytics = true
        lastAnalyticsCompletionHandler = completion
    }
    
    var lastAnalyticsPermissionGrantedValue: Bool!
    func updateAnalyticsPermission(permissionGranted: Bool) {
        lastAnalyticsPermissionGrantedValue = permissionGranted
    }
}
