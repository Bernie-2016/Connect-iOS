import Foundation
import KSDeferred

class ConcreteNewsFeedService: NewsFeedService {
    private let newsArticleRepository: NewsArticleRepository

    init(newsArticleRepository: NewsArticleRepository) {
        self.newsArticleRepository = newsArticleRepository
    }

    func fetchNewsFeed(completion: ([NewsFeedItem]) -> Void, error: (ErrorType) -> Void) {
        let promise: KSPromise = self.newsArticleRepository.fetchNewsArticles()

        promise.then({ (receivedNewsArticles) -> AnyObject? in
            guard let newsArticles = receivedNewsArticles as? Array<NewsArticle> else {
                let typeError = NSError(domain: "ConcreteNewsFeedService", code: 0, userInfo: nil)
                error(typeError)
                return receivedNewsArticles
            }
                completion(newsArticles.map({$0 as NewsFeedItem}))
                return receivedNewsArticles
            }) { (receivedError) -> AnyObject? in
                error(receivedError as ErrorType!)
                return receivedError
        }
    }
}
