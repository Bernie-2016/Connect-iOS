import Foundation
import CBGPromise

protocol NewsArticleRepository {
    func fetchNewsArticles() -> Future<Array<NewsArticle>, NSError>
}
