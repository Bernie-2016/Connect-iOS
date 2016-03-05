import Foundation
import CBGPromise


class BackgroundNewsFeedService: NewsFeedService {
    private let newsArticleRepository: NewsArticleRepository
    private let videoRepository: VideoRepository
    private let workerQueue: NSOperationQueue
    private let resultQueue: NSOperationQueue

    init(newsArticleRepository: NewsArticleRepository, videoRepository: VideoRepository, workerQueue: NSOperationQueue, resultQueue: NSOperationQueue) {
        self.newsArticleRepository = newsArticleRepository
        self.videoRepository = videoRepository
        self.workerQueue = workerQueue
        self.resultQueue = resultQueue
    }

    func fetchNewsFeed() -> NewsFeedFuture {
        let promise = NewsFeedPromise()

        workerQueue.addOperationWithBlock {
            var completedFutures = 0
            let numberOfRepositories = 2
            var errors = [ErrorType]()

            let newsFuture = self.newsArticleRepository.fetchNewsArticles()
            let videosFuture = self.videoRepository.fetchVideos()
            var newsArticles = Array<NewsFeedItem>()
            var videos = Array<NewsFeedItem>()

            let handleSuccess = {
                completedFutures += 1
                if completedFutures == numberOfRepositories {
                    let sortedNewsItems = self.sortNewsItems(videos, newsArticles: newsArticles)
                    self.resultQueue.addOperationWithBlock { promise.resolve(sortedNewsItems) }
                }
            }

            let handleFailure = { (receivedError: ErrorType) in
                completedFutures += 1
                errors.append(receivedError)
                if errors.count == numberOfRepositories {
                    let wrapperError = NewsFeedServiceError.FailedToFetchNews(underlyingErrors: errors)
                    self.resultQueue.addOperationWithBlock { promise.reject(wrapperError) }
                }
            }

            newsFuture.then { receivedNewsArticles in
                newsArticles = receivedNewsArticles.map({$0 as NewsFeedItem})
                handleSuccess()
            }
            newsFuture.error(handleFailure)

            videosFuture.then { receivedVideos in
                videos = receivedVideos.map({$0 as NewsFeedItem})
                handleSuccess()
            }
            videosFuture.error(handleFailure)
        }

        return promise.future
    }

    private func sortNewsItems(videos: Array<NewsFeedItem>, newsArticles: Array<NewsFeedItem>) -> Array<NewsFeedItem> {
        return [videos, newsArticles].flatMap({$0}).sort { $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
    }
}
