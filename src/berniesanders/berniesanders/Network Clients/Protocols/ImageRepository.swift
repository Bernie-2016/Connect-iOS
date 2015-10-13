import Foundation
import KSDeferred

protocol ImageRepository {
    func fetchImageWithURL(url: NSURL) -> KSPromise
}
