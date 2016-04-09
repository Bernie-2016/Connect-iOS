import UIKit

class URLOpener {
    init() {}

    func openURL(url: NSURL) {
        guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else {
            openURLInSafari(url)
            return
        }

        guard let host = urlComponents.host else {
            openURLInSafari(url)
            return
        }

        guard let path = urlComponents.path else {
            openURLInSafari(url)
            return
        }

        // https://m.facebook.com/l.php?u=https%3A%2F%2Fpanamapapers.icij.org%2F20160403-panama-papers-global-overview.html&h=CAQH1G6cv&enc=AZMg0YoIsykt6ZTqlFIxxTjWDX0teO7dMT_9nM-XrbLwTI-qWyaja_8PWQXBkglVINo&s=1

        if host != "m.facebook.com" && path != "/l.php" {
            openURLInSafari(url)
            return
        }

        guard let queryItems = urlComponents.queryItems else {
            openURLInSafari(url)
            return
        }

        var urlQueryItem: NSURLQueryItem?

        for queryItem in queryItems {
            if queryItem.name == "u" {
                urlQueryItem = queryItem
                break
            }
        }

        guard let urlString = urlQueryItem?.value else {
            openURLInSafari(url)
            return
        }

        guard let nonFBRedirectedURL = NSURL(string: urlString) else {
            openURLInSafari(url)
            return
        }

        openURLInSafari(nonFBRedirectedURL)
    }

    private func openURLInSafari(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
}
