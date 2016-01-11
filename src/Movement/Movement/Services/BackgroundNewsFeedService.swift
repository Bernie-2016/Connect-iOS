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

    func fetchNewsFeed(completion: ([NewsFeedItem]) -> Void, error: (ErrorType) -> Void) {
        workerQueue.addOperationWithBlock {
            var completedFutures = 0
            let numberOfRepositories = 2
            var errors = Array<NSError>()

            let newsFuture = self.newsArticleRepository.fetchNewsArticles()
            let videosFuture = self.videoRepository.fetchVideos()
            var newsArticles = Array<NewsFeedItem>()
            var videos = Array<NewsFeedItem>()

            let handleSuccess = {
                completedFutures += 1
                if completedFutures == numberOfRepositories {
                    let sortedNewsItems = self.sortNewsItems(videos, newsArticles: newsArticles)
                    self.resultQueue.addOperationWithBlock { completion(sortedNewsItems) }
                }
            }

            let handleFailure = { (receivedError: NSError) in
                completedFutures += 1
                errors.append(receivedError as NSError)
                if errors.count == numberOfRepositories {
                    let wrapperError = NSError(domain: "NewsFeedService", code: 0, userInfo: ["UnderlyingErrors": errors])
                    self.resultQueue.addOperationWithBlock { error(wrapperError) }
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
    }

    private func sortNewsItems(videos: Array<NewsFeedItem>, newsArticles: Array<NewsFeedItem>) -> Array<NewsFeedItem> {
        var sortedNewsItems = Array<NewsFeedItem>()

        let videosSortedByDate = videos.sort { $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
        var sortedRemainingItems: Array<NewsFeedItem>!
        if videosSortedByDate.count > 0 {
            sortedNewsItems.append(videosSortedByDate[0])
            sortedRemainingItems = [Array(videosSortedByDate[1..<videos.count]), newsArticles].flatMap({$0}).sort { $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
        } else {
            sortedRemainingItems = newsArticles.sort { $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
        }

        return sortedNewsItems + sortedRemainingItems
    }
}
