import Foundation

protocol ApplicationSettingsRepository {
    func termsAndConditionsAgreed(completion: (Bool) -> Void)
    func userAgreedToTerms(completion: (Void) -> Void)

    func isAnalyticsEnabled(completion: (Bool) -> Void)
    func updateAnalyticsPermission(permissionGranted: Bool)
}
