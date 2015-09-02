import Foundation
import KSDeferred

public protocol ImageRepository {
    func fetchImageWithURL(url: NSURL) -> KSPromise
}
