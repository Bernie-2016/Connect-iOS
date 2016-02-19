import Foundation
import CBGPromise

enum ImageRepositoryError: ErrorType {
    case DownloadError(error: NSError)
}

typealias ImageFuture = Future<UIImage, ImageRepositoryError>
typealias ImagePromise = Promise<UIImage, ImageRepositoryError>

protocol ImageRepository {
    func fetchImageWithURL(url: NSURL) -> ImageFuture
}
