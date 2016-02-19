import Foundation

protocol ImageService {
    func fetchImageWithURL(url: NSURL) -> ImageFuture
}
