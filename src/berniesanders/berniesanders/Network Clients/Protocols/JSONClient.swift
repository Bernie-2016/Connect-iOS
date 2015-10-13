import Foundation
import KSDeferred

protocol JSONClient {
    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> KSPromise
}
