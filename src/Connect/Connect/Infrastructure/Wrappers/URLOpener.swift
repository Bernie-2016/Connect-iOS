import UIKit

class URLOpener {
    init() {}

    func openURL(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
}
