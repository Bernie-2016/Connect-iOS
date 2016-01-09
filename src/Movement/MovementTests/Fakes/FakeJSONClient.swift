import CBGPromise
import Result

@testable import Movement

class FakeJSONClient: JSONClient {
    private (set) var promisesByURL = [NSURL: Promise<AnyObject, NSError>]()
    var lastMethod: String!
    var lastBodyDictionary: NSDictionary!

    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> Future<AnyObject, NSError> {
        let promise =  Promise<AnyObject, NSError>()
        self.promisesByURL[url] = promise
        self.lastMethod = method
        self.lastBodyDictionary = bodyDictionary
        return promise.future
    }
}
