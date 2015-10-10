import Foundation

public class ConcreteApplicationSettingsRepository: ApplicationSettingsRepository {
    private let userDefaults: NSUserDefaults

    private let kUserAgreedToTermsKey = "kUserAgreedToTermsKey"
    private let kAnalyticsPermissionsKey = "kAnalyticsPermissionsKey"

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

    public func isAnalyticsEnabled(completion:(Bool) -> Void) {
        completion(self.userDefaults.boolForKey(kAnalyticsPermissionsKey))
    }

    public func updateAnalyticsPermission(permissionGranted: Bool) {
        self.userDefaults.setBool(permissionGranted, forKey: kAnalyticsPermissionsKey)
    }
}

