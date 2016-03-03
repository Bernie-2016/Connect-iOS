import UIKit
@testable import Connect
import CoreLocation

class TestUtils {
    // MARK: Fixture loaders

    class func testImageNamed(named: String, type: String) -> UIImage {
        let bundle = NSBundle(forClass: TestUtils.self)
        let imagePath = bundle.pathForResource(named, ofType: type)!
        return UIImage(contentsOfFile: imagePath)!
    }

    class func dataFromFixtureFileNamed(named: String, type: String) -> NSData
    {
        let bundle = NSBundle(forClass: TestUtils.self)
        let path = bundle.pathForResource(named, ofType: type)
        return NSData(contentsOfFile: path!)!
    }

    // MARK: Models

    class func newsArticleWithoutImage() -> NewsArticle {
        return NewsArticle(title: "Bernie to release new album", date: NSDate(), body: "yeahhh", excerpt: "excerpt A", imageURL: nil, url: NSURL())
    }

    class func newsArticle(date: NSDate = NSDate(timeIntervalSince1970: 0)) -> NewsArticle {
        return NewsArticle(title: "Bernie to release new album", date: date, body: "yeahhh", excerpt: "excerpt A", imageURL: NSURL(string: "http://bs.com")!, url: NSURL())
    }

    class func video(date: NSDate = NSDate(timeIntervalSince1970: 0)) -> Video {
        return Video(title: "Bernie MegaMix", date: date, identifier: "XLveuzoauBo", description: "yay")
    }

    class func eventWithName(name: String) -> Event {
        return Event(name: name, startDate: NSDate(timeIntervalSince1970: 1433565000), timeZone: NSTimeZone(abbreviation: "PST")!,
            attendeeCapacity: 10, attendeeCount: 2,
            streetAddress: "100 Main Street", city: "Beverley Hills", state: "CA", zip: "90210", location: CLLocation(latitude: 37.8271868, longitude: -122.4240794),
            description: "This isn't Beverly Hills! It's Knot's Landing!", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")
    }

    class func eventWithStartDate(startDate: NSDate, timeZone: String) -> Event {
        return Event(name: startDate.description, startDate: startDate, timeZone: NSTimeZone(abbreviation: timeZone)!,
            attendeeCapacity: 10, attendeeCount: 2,
            streetAddress: "100 Main Street", city: "Beverley Hills", state: "CA", zip: "90210", location: CLLocation(latitude: 37.8271868, longitude: -122.4240794),
            description: "This isn't Beverly Hills! It's Knot's Landing!", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")
    }

    class func actionAlert(
        title: String = "Do it now",
        targetURL: NSURL? = NSURL(string: "https://example.com/fb")!,
        twitterURL: NSURL? = NSURL(string: "https://example.com/twit")!,
        tweetID: String? = "1800tweet") -> ActionAlert {
        return ActionAlert(
            identifier: "some-identifier",
            title: title,
            body: "I'm a cop you idiot",
            date: "Real soon now",
            targetURL: targetURL,
            twitterURL: twitterURL,
            tweetID: tweetID)
    }

    // MARK: Controllers

    class func settingsController() -> SettingsController {
        return SettingsController(tappableControllers: [self.privacyPolicyController()], analyticsService: FakeAnalyticsService(), tabBarItemStylist: FakeTabBarItemStylist(), theme: FakeTheme())
    }

    class func termsAndConditionsController() -> TermsAndConditionsController {
        return TermsAndConditionsController(analyticsService: FakeAnalyticsService())
    }

    class func privacyPolicyController() -> PrivacyPolicyController {
        return PrivacyPolicyController(urlProvider: FakeURLProvider(), analyticsService: FakeAnalyticsService())
    }

    class func eventRSVPController() -> EventRSVPController {
        return EventRSVPController(event: self.eventWithName("some event"), analyticsService: FakeAnalyticsService(), theme: FakeTheme())
    }

    class func welcomeController() -> WelcomeController {
        return WelcomeController(applicationSettingsRepository: FakeApplicationSettingsRepository(), termsAndConditionsController: self.termsAndConditionsController(), privacyPolicyController: self.privacyPolicyController(), analyticsService: FakeAnalyticsService(), theme: FakeTheme())
    }

    class func actionAlertController() -> ActionAlertController {
        let actionAlert = self.actionAlert()
        return ActionAlertController(actionAlert: actionAlert, markdownConverter: FakeMarkdownConverter(), urlOpener: FakeURLOpener(), urlProvider: FakeURLProvider(), analyticsService: FakeAnalyticsService(), theme: FakeTheme())
    }
}
