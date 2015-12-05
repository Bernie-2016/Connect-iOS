import Foundation

protocol NewsFeedService {
    func fetchNewsFeed(completion: ([NewsFeedItem]) -> Void, error: (ErrorType) -> Void)
}
