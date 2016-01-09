import Foundation
import CBGPromise
import Result
@testable import Movement


class FakeImageRepository : Movement.ImageRepository {
    var lastReceivedURL : NSURL?
    var lastRequestPromise : Promise<UIImage, NSError>!
    var imageRequested = false

    func fetchImageWithURL(url: NSURL) -> Future<UIImage, NSError> {
        self.lastReceivedURL = url
        self.lastRequestPromise = Promise<UIImage, NSError>()
        self.imageRequested = true
        return self.lastRequestPromise.future
    }
}
