import Foundation
@testable import Movement

class FakeURLOpener : Movement.URLOpener {
    var lastOpenedURL : NSURL!

    override func openURL(url: NSURL) {
        self.lastOpenedURL = url
    }
}
