import berniesanders
import Foundation
import KSDeferred

class FakeJSONClient: berniesanders.JSONClient {
    private (set) var deferredsByURL = [NSURL: KSDeferred]()
    
    func fetchJSONWithURL(url: NSURL) -> KSPromise {
        var deferred =  KSDeferred.defer()
        self.deferredsByURL[url] = deferred
        return deferred.promise
    }
}