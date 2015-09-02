import Foundation
import KSDeferred
import berniesanders


class FakeImageRepository : berniesanders.ImageRepository {
    var lastReceivedURL : NSURL?
    var lastRequestDeferred : KSDeferred!
    
    func fetchImageWithURL(url: NSURL) -> KSPromise {
        self.lastReceivedURL = url
        self.lastRequestDeferred = KSDeferred()
        return self.lastRequestDeferred.promise
    }
}
