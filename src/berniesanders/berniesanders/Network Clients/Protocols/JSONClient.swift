import Foundation
import KSDeferred

public protocol JSONClient {
    func fetchJSONWithURL(url: NSURL) -> KSPromise
}