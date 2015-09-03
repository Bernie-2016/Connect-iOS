import UIKit

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
}
