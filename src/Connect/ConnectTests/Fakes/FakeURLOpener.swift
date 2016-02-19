import Foundation

@testable import Connect

class FakeURLOpener: URLOpener {
    var lastOpenedURL : NSURL!

    override func openURL(url: NSURL) {
        self.lastOpenedURL = url
    }
}
