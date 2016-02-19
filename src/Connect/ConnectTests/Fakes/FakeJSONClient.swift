import CBGPromise

@testable import Connect

class FakeJSONClient: JSONClient {
    private (set) var promisesByURL = [NSURL: JSONPromise]()
    var lastMethod: String!
    var lastBodyDictionary: NSDictionary!

    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> JSONFuture {
        let promise =  JSONPromise()
        self.promisesByURL[url] = promise
        self.lastMethod = method
        self.lastBodyDictionary = bodyDictionary
        return promise.future
    }
}
