import Foundation

class APIKeyProvider {
    let plist: NSDictionary

    init() {
        let filePath = NSBundle.mainBundle().pathForResource("ApiKeys", ofType:"plist")
        self.plist = NSDictionary(contentsOfFile:filePath!)!
    }

    func flurryAPIKey() -> String {
        guard let apiKey = self.plist.objectForKey("FLURRY_API_KEY") as? String else { return "KEY_NOT_FOUND" }
        return apiKey
    }

    func parseApplicationId() -> String {
        guard let applicationId = self.plist.objectForKey("PARSE_APPLICATION_ID") as? String else { return "KEY_NOT_FOUND" }
        return applicationId
    }

    func parseClientKey() -> String {
        guard let clientKey = self.plist.objectForKey("PARSE_CLIENT_KEY") as? String else { return "KEY_NOT_FOUND" }
        return clientKey
    }
}
