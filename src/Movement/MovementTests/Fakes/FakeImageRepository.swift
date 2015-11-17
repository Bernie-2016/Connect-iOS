import Foundation
import KSDeferred
@testable import Movement


class FakeImageRepository : Movement.ImageRepository {
    var lastReceivedURL : NSURL?
    var lastRequestDeferred : KSDeferred!
    var imageRequested = false

    func fetchImageWithURL(url: NSURL) -> KSPromise {
        self.lastReceivedURL = url
        self.lastRequestDeferred = KSDeferred()
        self.imageRequested = true
        return self.lastRequestDeferred.promise
    }
}
