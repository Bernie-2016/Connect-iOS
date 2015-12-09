import Foundation
import BrightFutures
import Result

class ConcreteNewsFeedService: NewsFeedService {
    private let newsArticleRepository: NewsArticleRepository

    init(newsArticleRepository: NewsArticleRepository) {
        self.newsArticleRepository = newsArticleRepository
    }

    func fetchNewsFeed(completion: ([NewsFeedItem]) -> Void, error: (ErrorType) -> Void) {
        let future = self.newsArticleRepository.fetchNewsArticles()

        future.onSuccess() { (receivedNewsArticles) -> Void in
            completion(receivedNewsArticles.map({$0 as NewsFeedItem}))
        }.onFailure() { (receivedError) -> Void in
            error(receivedError)
        }
    }
}
