import Foundation
import CBGPromise

protocol JSONClient {
    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> Future<AnyObject, NSError>
}
