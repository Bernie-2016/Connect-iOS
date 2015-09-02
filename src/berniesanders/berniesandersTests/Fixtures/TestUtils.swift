import UIKit

class TestUtils {
    class func testImageNamed(named: String, type: String) -> UIImage {
        var bundle = NSBundle(forClass: NewsItemControllerSpec.self)
        var imagePath = bundle.pathForResource(named, ofType: type)!
        return UIImage(contentsOfFile: imagePath)!
    }
}
