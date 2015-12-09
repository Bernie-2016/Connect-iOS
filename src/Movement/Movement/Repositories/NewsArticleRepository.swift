import Foundation
import BrightFutures

protocol NewsArticleRepository {
    func fetchNewsArticles() -> Future<Array<NewsArticle>, NSError>
}
