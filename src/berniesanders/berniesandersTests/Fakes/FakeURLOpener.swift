import Foundation
import berniesanders

public class FakeURLOpener : berniesanders.URLOpener {
    var lastOpenedURL : NSURL!

    override public func openURL(url: NSURL) {
        self.lastOpenedURL = url
    }
}