import Foundation
import BrightFutures

protocol JSONClient {
    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> Future<AnyObject, NSError>
}
