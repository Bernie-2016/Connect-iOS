import Foundation
import CoreLocation

class ConcreteURLProvider: URLProvider {
    init() {}

    func issuesFeedURL() -> NSURL {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search")!
    }

    func newsFeedURL() -> NSURL {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search")!
    }

    func bernieCrowdURL() -> NSURL {
        return NSURL(string: "https://berniecrowd.org/")!
    }

    func privacyPolicyURL() -> NSURL {
        return NSURL(string: "https://www.iubenda.com/privacy-policy/128001")!
    }

    func eventsURL() -> NSURL {
        return NSURL(string: "https://search.berniesanders.tech/events/berniesanders_com/_search")!
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

    func codersForSandersURL() -> NSURL {
        return NSURL(string: "https://www.reddit.com/r/codersforsanders")!
    }

    func designersForSandersURL() -> NSURL {
        return NSURL(string: "https://www.reddit.com/r/designersforsanders")!
    }

    func sandersForPresidentURL() -> NSURL {
        return NSURL(string: "https://www.reddit.com/r/sandersforpresident")!
    }

    func feedbackFormURL() -> NSURL {
        let urlComponents = NSURLComponents(string: "https://docs.google.com/forms/d/1i9eX_pmZxS5thQow6x7L_JC1-gv5qSAwJJ4aD3RdTDg/viewform")!

        let marketingVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? "unknown version"
        let internalBuildNumber  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String  ?? "unknown build"

        let versionString = "\(marketingVersion) (\(internalBuildNumber))"
        let versionQueryItem = NSURLQueryItem(name: "entry.1652819874", value: versionString)

        urlComponents.queryItems = [versionQueryItem]
        return urlComponents.URL!
    }

    func donateFormURL() -> NSURL {
        return NSURL(string: "https://secure.actblue.com/contribute/page/lets-go-bernie?refcode=berniesanders_iosApp")!
    }

    func createEventURL() -> NSURL {
        return NSURL(string: "https://go.berniesanders.com/page/event/create#eventcreate")!
    }

    func videoURL() -> NSURL {
        return NSURL(string: "https://search.berniesanders.tech/videos_v1/_search")!
    }

    func youtubeVideoURL(identifier: String) -> NSURL {
        fatalError("test drive me!")
    }
}
