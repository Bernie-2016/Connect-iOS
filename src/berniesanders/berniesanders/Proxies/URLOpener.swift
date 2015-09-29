import UIKit

public class URLOpener {
    public init () {}
    
    public func openURL(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
}