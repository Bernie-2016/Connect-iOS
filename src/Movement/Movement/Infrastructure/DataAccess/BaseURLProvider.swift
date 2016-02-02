import Foundation

class BaseURLProvider {
    let plist: NSDictionary

    init() {
        let filePath = NSBundle.mainBundle().pathForResource("BaseURLs", ofType:"plist")
        self.plist = NSDictionary(contentsOfFile:filePath!)!
    }

    func sharknadoBaseURL() -> NSURL {
        guard let urlString = self.plist.objectForKey("SHARKNADO_BASE_URL") as? String else { fatalError("SHARKNADO BASE URL NOT FOUND") }
        let url = NSURL(string: urlString)!
        return url
    }

    func connectBaseURL() -> NSURL {
        guard let urlString = self.plist.objectForKey("CONNECT_BASE_URL") as? String else { fatalError("CONNECT BASE URL NOT FOUND") }
        let url = NSURL(string: urlString)!
        return url
    }
}
