import Foundation
import CBGPromise

typealias ImageFuture = Future<UIImage, NSError>
typealias ImagePromise = Promise<UIImage, NSError>


protocol ImageRepository {
    func fetchImageWithURL(url: NSURL) -> ImageFuture
}
