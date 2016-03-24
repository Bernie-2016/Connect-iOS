import Foundation
import CoreLocation

class ConcreteURLProvider: URLProvider {
    let sharknadoBaseURL: NSURL
    let connectBaseURL: NSURL

    init(sharknadoBaseURL: NSURL, connectBaseURL: NSURL) {
        self.sharknadoBaseURL = sharknadoBaseURL
        self.connectBaseURL = connectBaseURL
    }

    func newsFeedURL() -> NSURL {
        return NSURL(string: "/articles_en_v1/berniesanders_com/_search", relativeToURL: sharknadoBaseURL)!
    }

    func eventsURL() -> NSURL {
        return NSURL(string: "/events_en_v1/berniesanders_com/_search", relativeToURL: sharknadoBaseURL)!
    }

    func videoURL() -> NSURL {
        return NSURL(string: "/videos_v1/_search", relativeToURL: sharknadoBaseURL)!
    }

    func privacyPolicyURL() -> NSURL {
        return NSURL(string: "https://berniesanders.com/privacy-policy/#post-424")!
    }

    func mapsURLForEvent(event: Event) -> NSURL {
        let urlString: String!
        if event.streetAddress != nil {
            urlString = String(format: "https://maps.apple.com/?address=%@,%@,%@,%@", event.streetAddress!, event.city, event.state, event.zip)
        } else {
            urlString = String(format: "https://maps.apple.com/?address=%@,%@,%@", event.city, event.state, event.zip)
        }
        return NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)!
    }

    func githubURL() -> NSURL {
        return NSURL(string: "https://github.com/Bernie-2016/Connect-iOS")!
    }

    func slackURL() -> NSURL {
        return NSURL(string: "https://connectwithbernieslack.herokuapp.com/")!
    }

    func feedbackFormURL() -> NSURL {
        let urlComponents = NSURLComponents(string: "https://docs.google.com/forms/d/1gE0hwL9AaUjovr4QE_0oD0A1BT1lB3GGGktHB8amHXs/viewform")!

        let marketingVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? "unknown version"
        let internalBuildNumber  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String  ?? "unknown build"

        let versionString = "iOS: \(marketingVersion) (\(internalBuildNumber))"
        let versionQueryItem = NSURLQueryItem(name: "entry.1777259581", value: versionString)

        urlComponents.queryItems = [versionQueryItem]
        return urlComponents.URL!
    }

    func donateFormURL() -> NSURL {
        return NSURL(string: "https://secure.actblue.com/contribute/page/lets-go-bernie?refcode=Connect_iosApp")!
    }

    func hostEventFormURL() -> NSURL {
        return NSURL(string: "https://go.berniesanders.com/page/event/create#eventcreate")!
    }

    func youtubeVideoURL(identifier: String) -> NSURL {
        let urlComponents = NSURLComponents(string: "https://www.youtube.com/watch")!
        let videoIdentifierQueryItem = NSURLQueryItem(name: "v", value: identifier)
        urlComponents.queryItems = [videoIdentifierQueryItem]

        return urlComponents.URL!
    }

    func youtubeThumbnailURL(identifier: String) -> NSURL {
        let urlComponents = NSURLComponents(string: "https://img.youtube.com/")!

        let basePath = ("/vi" as NSString).stringByAppendingPathComponent(identifier) as NSString
        let fullPath = basePath.stringByAppendingPathComponent("hqdefault.jpg")
        urlComponents.path = fullPath

        return urlComponents.URL!
    }

    func actionAlertsURL() -> NSURL {
        return NSURL(string: "/api/action_alerts", relativeToURL: connectBaseURL)!
    }

    func twitterShareURL(urlToShare: NSURL) -> NSURL {
        let urlComponents = NSURLComponents(string: "https://twitter.com/share")!
        let urlQueryItem = NSURLQueryItem(name: "url", value: urlToShare.absoluteString)
        let textQueryItem = NSURLQueryItem(name: "text", value: NSLocalizedString("url_TwitterShareText", comment: ""))
        urlComponents.queryItems = [urlQueryItem, textQueryItem]

        return urlComponents.URL!
    }

    func retweetURL(tweetID: TweetID) -> NSURL {
        let urlComponents = NSURLComponents(string: "https://twitter.com/intent/retweet")!
        let tweetIDQueryItem = NSURLQueryItem(name: "tweet_id", value: tweetID)
        urlComponents.queryItems = [tweetIDQueryItem]

        return urlComponents.URL!
    }

    func actionAlertURL(identifier: ActionAlertIdentifier) -> NSURL {
        var pathString = "/api/action_alerts"
        pathString = pathString.stringByAppendingString("/\(identifier)")

        return NSURL(string: pathString, relativeToURL: connectBaseURL)!
    }
}
