import Foundation
import CBGPromise

enum NewsArticleRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
    case NoMatchingNewsArticle(identifier: NewsArticleIdentifier)
}

typealias NewsArticlesFuture = Future<[NewsArticle], NewsArticleRepositoryError>
typealias NewsArticlesPromise = Promise<[NewsArticle], NewsArticleRepositoryError>
typealias NewsArticleFuture = Future<NewsArticle, NewsArticleRepositoryError>
typealias NewsArticlePromise = Promise<NewsArticle, NewsArticleRepositoryError>

protocol NewsArticleRepository {
    func fetchNewsArticles() -> NewsArticlesFuture
    func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture
}
