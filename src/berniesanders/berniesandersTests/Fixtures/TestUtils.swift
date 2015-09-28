import UIKit
import berniesanders

class TestUtils {
    // MARK: Fixture loaders
    
    class func testImageNamed(named: String, type: String) -> UIImage {
        var bundle = NSBundle(forClass: NewsItemControllerSpec.self)
        var imagePath = bundle.pathForResource(named, ofType: type)!
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
        return Issue(title: "An issue title made by TestUtils", body: "An issue body made by TestUtils", imageURL: NSURL(string: "http://1wdojq181if3tdg01yomaof86.wpengine.netdna-cdn.com/wp-content/uploads/2015/05/Sanders.jpg")!, URL: NSURL(string: "http://a.com")!)
    }
    
    class func eventWithName(name: String) -> Event {
        return Event(name: name, attendeeCapacity: 10, attendeeCount: 2, city: "Beverley Hills", state: "CA", zip: "90210", description: "This isn't Beverly Hills! It's Knot's Landing!", URL: NSURL(string: "https://example.com")!)
    }
    
    // MARK: Controllers
    
    class func settingsController() -> SettingsController {
        return SettingsController(privacyPolicyController: self.privacyPolicyController(), theme: FakeTheme())
    }
    
    class func privacyPolicyController() -> PrivacyPolicyController {
        return PrivacyPolicyController(urlProvider: FakeURLProvider())
    }
}
