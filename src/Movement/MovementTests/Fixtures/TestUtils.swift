import UIKit
@testable import Movement
import CoreLocation

class TestUtils {
    // MARK: Fixture loaders

    class func testImageNamed(named: String, type: String) -> UIImage {
        let bundle = NSBundle(forClass: NewsArticleControllerSpec.self)
        let imagePath = bundle.pathForResource(named, ofType: type)!
        return UIImage(contentsOfFile: imagePath)!
    }

    class func dataFromFixtureFileNamed(named: String, type: String) -> NSData
    {
        let bundle = NSBundle(forClass: ConcreteIssueDeserializerSpec.self)
        let path = bundle.pathForResource(named, ofType: type)
        return NSData(contentsOfFile: path!)!
    }

    // MARK: Models

    class func issue() -> Issue {
        return Issue(title: "An issue title made by TestUtils", body: "An issue body made by TestUtils", imageURL: NSURL(string: "http://1wdojq181if3tdg01yomaof86.wpengine.netdna-cdn.com/wp-content/uploads/2015/05/Sanders.jpg")!, url: NSURL(string: "http://issue.com/issue/a")!)
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
        return ActionAlertController(actionAlert: actionAlert, markdownConverter: FakeMarkdownConverter(), urlOpener: FakeURLOpener(), urlProvider: FakeURLProvider(), theme: FakeTheme())
    }
}
