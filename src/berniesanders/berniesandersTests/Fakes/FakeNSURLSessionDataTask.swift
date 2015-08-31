import Foundation


class FakeNSURLSessionDataTask : NSURLSessionDataTask {
    var resumeCalled : Bool = false
    
    override func resume() {
        self.resumeCalled = true
    }
}
