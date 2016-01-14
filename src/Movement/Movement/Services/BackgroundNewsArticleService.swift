class BackgroundNewsArticleService: NewsArticleService {
    let newsArticleRepository: NewsArticleRepository
    let workerQueue: NSOperationQueue
    let resultQueue: NSOperationQueue

    init(newsArticleRepository: NewsArticleRepository, workerQueue: NSOperationQueue, resultQueue: NSOperationQueue) {
        self.newsArticleRepository = newsArticleRepository
        self.workerQueue = workerQueue
        self.resultQueue = resultQueue
    }

    func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture {
        let promise = NewsArticlePromise()

        workerQueue.addOperationWithBlock {
            let newsArticleFuture = self.newsArticleRepository.fetchNewsArticle(identifier)

            newsArticleFuture.then { newsArticle in
                self.resultQueue.addOperationWithBlock { promise.resolve(newsArticle) }
                }.error { error in
                self.resultQueue.addOperationWithBlock { promise.reject(error) }
            }
        }

        return promise.future
    }
}
