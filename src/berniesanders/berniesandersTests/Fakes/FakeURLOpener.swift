import Foundation
@testable import berniesanders

class FakeURLOpener : berniesanders.URLOpener {
    var lastOpenedURL : NSURL!

    override func openURL(url: NSURL) {
        self.lastOpenedURL = url
    }
}
