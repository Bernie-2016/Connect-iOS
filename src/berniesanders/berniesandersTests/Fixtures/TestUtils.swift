import UIKit
@testable import berniesanders
import CoreLocation

class TestUtils {
    // MARK: Fixture loaders

    class func testImageNamed(named: String, type: String) -> UIImage {
        let bundle = NSBundle(forClass: NewsItemControllerSpec.self)
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

    class func eventWithName(name: String) -> Event {
        return Event(name: name, startDate: NSDate(timeIntervalSince1970: 1433565000), timeZone: NSTimeZone(abbreviation: "PST")!,
            attendeeCapacity: 10, attendeeCount: 2,
            streetAddress: "100 Main Street", city: "Beverley Hills", state: "CA", zip: "90210", location: CLLocation(),
            description: "This isn't Beverly Hills! It's Knot's Landing!", url: NSURL(string: "https://example.com")!)
    }

    // MARK: Controllers

    class func settingsController() -> SettingsController {
        return SettingsController(tappableControllers: [self.privacyPolicyController()], urlOpener: FakeURLOpener(), urlProvider: FakeURLProvider(), analyticsService: FakeAnalyticsService(), tabBarItemStylist: FakeTabBarItemStylist(), theme: FakeTheme())
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
}
