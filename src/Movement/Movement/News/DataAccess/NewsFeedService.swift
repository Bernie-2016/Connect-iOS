import Foundation

enum NewsFeedServiceError: ErrorType {
    case FailedToFetchNews(underlyingErrors: [ErrorType])
}


protocol NewsFeedService {
    func fetchNewsFeed(completion: ([NewsFeedItem]) -> Void, error: (NewsFeedServiceError) -> Void)
}
