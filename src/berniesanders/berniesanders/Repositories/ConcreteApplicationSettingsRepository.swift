import Foundation

class ConcreteApplicationSettingsRepository: ApplicationSettingsRepository {
    private let userDefaults: NSUserDefaults

    private let kUserAgreedToTermsKey = "kUserAgreedToTermsKey"
    private let kAnalyticsPermissionsKey = "kAnalyticsPermissionsKey"

    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
    }

    func termsAndConditionsAgreed(completion: (Bool) -> Void) {
        let userAgreedToTermsOnDate: AnyObject? = self.userDefaults.objectForKey(kUserAgreedToTermsKey)

        completion(userAgreedToTermsOnDate != nil)
    }

    func userAgreedToTerms(completion: (Void) -> Void) {
        self.userDefaults.setObject(NSDate(), forKey: kUserAgreedToTermsKey)
        completion()
    }

    func isAnalyticsEnabled(completion:(Bool) -> Void) {
        completion(self.userDefaults.boolForKey(kAnalyticsPermissionsKey))
    }

    func updateAnalyticsPermission(permissionGranted: Bool) {
        self.userDefaults.setBool(permissionGranted, forKey: kAnalyticsPermissionsKey)
    }
}

