import Foundation
import CBGPromise

enum NewsFeedServiceError: ErrorType {
    case FailedToFetchNews(underlyingErrors: [ErrorType])
}

typealias NewsFeedPromise = Promise<[NewsFeedItem], NewsFeedServiceError>
typealias NewsFeedFuture = Future<[NewsFeedItem], NewsFeedServiceError>

protocol NewsFeedService {
    func fetchNewsFeed() -> NewsFeedFuture
}
