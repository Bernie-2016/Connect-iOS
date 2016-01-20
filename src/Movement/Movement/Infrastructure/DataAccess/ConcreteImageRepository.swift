import Foundation
import WebImage
import CBGPromise

class ConcreteImageRepository: ImageRepository {
    private let webImageManager: SDWebImageManager

    init(webImageManager: SDWebImageManager) {
        self.webImageManager = webImageManager
    }

    func fetchImageWithURL(url: NSURL) -> ImageFuture {
        let promise = ImagePromise()

        self.webImageManager.downloadImageWithURL(url, options: SDWebImageOptions(), progress: nil) { (image, error, cacheType, finished, imageURL) -> Void in
            if error != nil {
                let downloadError = ImageRepositoryError.DownloadError(error: error)
                promise.reject(downloadError)
            } else {
                promise.resolve(image)
            }
        }

        return promise.future
    }
}
