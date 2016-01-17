import Foundation
import CBGPromise

typealias NewsArticlesFuture = Future<[NewsArticle], NSError>
typealias NewsArticlesPromise = Promise<[NewsArticle], NSError>
typealias NewsArticleFuture = Future<NewsArticle, NSError>
typealias NewsArticlePromise = Promise<NewsArticle, NSError>

protocol NewsArticleRepository {
    func fetchNewsArticles() -> NewsArticlesFuture
    func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture
}
