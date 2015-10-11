import Foundation
import KSDeferred
import WebImage

public class ConcreteImageRepository: ImageRepository {
    private let webImageManager: SDWebImageManager

    public init(webImageManager: SDWebImageManager) {
        self.webImageManager = webImageManager
    }

    public func fetchImageWithURL(url: NSURL) -> KSPromise {
        let deferred = KSDeferred()

        self.webImageManager.downloadImageWithURL(url, options: SDWebImageOptions(), progress: nil) { (image, error, cacheType, finished, imageURL) -> Void in
            if(error != nil) {
                deferred.rejectWithError(error)
            } else {
                deferred.resolveWithValue(image)
            }
        }

        return deferred.promise
    }
}
