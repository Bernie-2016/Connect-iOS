import Foundation

class BaseURLProvider {
    let plist: NSDictionary

    init() {
        let filePath = NSBundle.mainBundle().pathForResource("BaseURLs", ofType:"plist")
        self.plist = NSDictionary(contentsOfFile:filePath!)!
    }

    func sharknadoBaseURL() -> NSURL {
        return urlFromPlist("SHARKNADO_BASE_URL")
    }

    func connectBaseURL() -> NSURL {
        return urlFromPlist("CONNECT_BASE_URL")
    }

    private func urlFromPlist(key: String) -> NSURL {
        guard let urlString = self.plist.objectForKey(key) as? String else { fatalError("\(key) NOT FOUND") }
        let url = NSURL(string: urlString)!
        return url
    }
}
