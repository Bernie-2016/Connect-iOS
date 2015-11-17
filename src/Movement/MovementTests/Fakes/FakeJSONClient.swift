@testable import Movement
import Foundation
import KSDeferred

class FakeJSONClient: Movement.JSONClient {
    private (set) var deferredsByURL = [NSURL: KSDeferred]()
    var lastMethod: String!
    var lastBodyDictionary: NSDictionary!

    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> KSPromise {
        let deferred =  KSDeferred.`defer`()
        self.deferredsByURL[url] = deferred
        self.lastMethod = method
        self.lastBodyDictionary = bodyDictionary
        return deferred.promise
    }
}
