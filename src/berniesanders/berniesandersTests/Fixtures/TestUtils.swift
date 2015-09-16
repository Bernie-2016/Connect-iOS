import UIKit
import berniesanders

class TestUtils {
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
    
    class func issue() -> Issue {
        return Issue(title: "An issue title made by TestUtils", body: "An issue body made by TestUtils", imageURL: NSURL(string: "http://1wdojq181if3tdg01yomaof86.wpengine.netdna-cdn.com/wp-content/uploads/2015/05/Sanders.jpg")!, URL: NSURL(string: "http://a.com")!)
    }
    
    class func settingsController() -> SettingsController {
        return SettingsController()
    }
}
