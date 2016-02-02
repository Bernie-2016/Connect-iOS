import Foundation
import CBGPromise

enum NewsArticleRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
    case NoMatchingNewsArticle(identifier: NewsArticleIdentifier)
}

extension NewsArticleRepositoryError: Equatable {}

func == (lhs: NewsArticleRepositoryError, rhs: NewsArticleRepositoryError) -> Bool {
    switch (lhs, rhs) {
    case (.InvalidJSON, .InvalidJSON):
        return true // punt on this for now.
    case (.ErrorInJSONClient(let lhsJSONClientError), .ErrorInJSONClient(let rhsJSONClientError)):
        return lhsJSONClientError == rhsJSONClientError
    case (.NoMatchingNewsArticle(let lhsIdentifier), .NoMatchingNewsArticle(let rhsIdentifier)):
        return lhsIdentifier == rhsIdentifier
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}


typealias NewsArticlesFuture = Future<[NewsArticle], NewsArticleRepositoryError>
typealias NewsArticlesPromise = Promise<[NewsArticle], NewsArticleRepositoryError>
typealias NewsArticleFuture = Future<NewsArticle, NewsArticleRepositoryError>
typealias NewsArticlePromise = Promise<NewsArticle, NewsArticleRepositoryError>

protocol NewsArticleRepository {
    func fetchNewsArticles() -> NewsArticlesFuture
    func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture
}
