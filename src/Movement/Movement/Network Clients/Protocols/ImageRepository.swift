import Foundation
import BrightFutures

protocol ImageRepository {
    func fetchImageWithURL(url: NSURL) -> Future<UIImage, NSError>
}
