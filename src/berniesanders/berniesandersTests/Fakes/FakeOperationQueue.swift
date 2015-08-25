import Foundation

class FakeOperationQueue : NSOperationQueue {
    var lastReceivedBlock: (() -> Void)!
    
    override init() {
        
    }
    
    override func addOperationWithBlock(block: () -> Void) {
        self.lastReceivedBlock = block
    }
}
