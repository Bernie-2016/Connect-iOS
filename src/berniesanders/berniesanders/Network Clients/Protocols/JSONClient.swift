import Foundation
import KSDeferred

public protocol JSONClient {
    func fetchJSONWithURL(url: NSURL) -> KSPromise
    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> KSPromise
}