import Foundation
import KSDeferred

protocol NewsArticleRepository {
    func fetchNewsArticles() -> KSPromise
}
