import Foundation

class FakeNSURLSession : NSURLSession {
    var lastURL: NSURL!
    var lastRequest: NSURLRequest!
    var lastCompletionHandler : ((NSData!, NSURLResponse!, NSError!) -> Void)?
    var lastReturnedTask : FakeNSURLSessionDataTask!
    
    override init() {
        
    }
    
    override func dataTaskWithURL(url: NSURL, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)) -> NSURLSessionDataTask {
        self.lastURL = url
        self.lastReturnedTask = FakeNSURLSessionDataTask()
        self.lastCompletionHandler = completionHandler
        return self.lastReturnedTask
    }
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)) -> NSURLSessionDataTask {
        self.lastRequest = request
        self.lastReturnedTask = FakeNSURLSessionDataTask()
        self.lastCompletionHandler = completionHandler
        return self.lastReturnedTask
    }
}