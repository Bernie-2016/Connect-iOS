import Foundation

class ConcreteNewsFeedService: NewsFeedService {
    private let newsArticleRepository: NewsArticleRepository

    init(newsArticleRepository: NewsArticleRepository) {
        self.newsArticleRepository = newsArticleRepository
    }

    func fetchNewsFeed(completion: ([NewsFeedItem]) -> Void, error: (ErrorType) -> Void) {
        self.newsArticleRepository.fetchNewsArticles({ (receivedNewsArticles) -> Void in
            completion(receivedNewsArticles.map({$0 as NewsFeedItem}))
            }, error: { (newsArticleError) -> Void in
                error(newsArticleError)
        })
    }
}
