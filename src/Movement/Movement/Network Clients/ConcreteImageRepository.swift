import Foundation
import BrightFutures
import Result
import WebImage

class ConcreteImageRepository: ImageRepository {
    private let webImageManager: SDWebImageManager

    init(webImageManager: SDWebImageManager) {
        self.webImageManager = webImageManager
    }

    func fetchImageWithURL(url: NSURL) -> Future<UIImage, NSError> {
        let promise = Promise<UIImage, NSError>()

        self.webImageManager.downloadImageWithURL(url, options: SDWebImageOptions(), progress: nil) { (image, error, cacheType, finished, imageURL) -> Void in
            if error != nil {
                promise.failure(error)
            } else {
                promise.success(image)
            }
        }

        return promise.future
    }
}
