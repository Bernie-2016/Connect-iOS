import berniesanders
import Foundation
import KSDeferred

class FakeJSONClient: berniesanders.JSONClient {
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
