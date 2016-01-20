import Quick
import Nimble
import CBGPromise

@testable import Movement

class BackgroundNewsFeedServiceSpec: QuickSpec {
    override func spec() {
        describe("BackgroundNewsFeedService") {
            var subject: BackgroundNewsFeedService!
            var newsArticleRepository: FakeNewsArticleRepository!
            var videoRepository: FakeVideoRepository!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!

            beforeEach {
                newsArticleRepository = FakeNewsArticleRepository()
                videoRepository = FakeVideoRepository()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = BackgroundNewsFeedService(
                    newsArticleRepository: newsArticleRepository,
                    videoRepository: videoRepository,
                    workerQueue: workerQueue,
                    resultQueue: resultQueue
                )
            }
            describe("fetching the news feed") {
                var newsFeedFuture: NewsFeedFuture!

                beforeEach {
                    newsFeedFuture = subject.fetchNewsFeed()
                }

                it("asks the news article repository to fetch some news articles on the worker queue") {
                    expect(newsArticleRepository.fetchNewsCalled).to(beFalse())

                    workerQueue.lastReceivedBlock()

                    expect(newsArticleRepository.fetchNewsCalled).to(beTrue())
                }

                it("asks the video repository to fetch some videos on the worker queue") {
                    expect(videoRepository.fetchVideosCalled).to(beFalse())

                    workerQueue.lastReceivedBlock()

                    expect(videoRepository.fetchVideosCalled).to(beTrue())
                }

                describe("when both the news article repo and video repo returns some objects") {
                    beforeEach { workerQueue.lastReceivedBlock() }

                    it("calls the completion handler with the news feed items, with the most recent video first and the rest of the news feed items sorted by date") {
                        let newsArticleA = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 5))
                        let newsArticleB = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 4))
                        let newsArticleC = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 2))

                        let videoA  = TestUtils.video(NSDate(timeIntervalSince1970: 4))
                        let videoB  = TestUtils.video(NSDate(timeIntervalSince1970: 3))

                        newsArticleRepository.lastPromise.resolve([newsArticleC, newsArticleA, newsArticleB])
                        videoRepository.lastPromise.resolve([videoB, videoA])

                        resultQueue.lastReceivedBlock()

                        let receivedNewsFeedItems = newsFeedFuture.value!
                        expect(receivedNewsFeedItems.count).to(equal(5))
                        expect(receivedNewsFeedItems[0] as? Video).to(beIdenticalTo(videoA))
                        expect(receivedNewsFeedItems[1] as? NewsArticle).to(beIdenticalTo(newsArticleA))
                        expect(receivedNewsFeedItems[2] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                        expect(receivedNewsFeedItems[3] as? Video).to(beIdenticalTo(videoB))
                        expect(receivedNewsFeedItems[4] as? NewsArticle).to(beIdenticalTo(newsArticleC))
                    }
                }

                describe("when no videos are returned") {
                    beforeEach { workerQueue.lastReceivedBlock() }

                    it("calls the completion handler with only the news articles, sorted by date, on the result queue") {
                        let newsArticleA = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 5))
                        let newsArticleB = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 4))
                        let newsArticleC = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 2))

                        newsArticleRepository.lastPromise.resolve([newsArticleC, newsArticleA, newsArticleB])
                        videoRepository.lastPromise.resolve([])

                        resultQueue.lastReceivedBlock()

                        let receivedNewsFeedItems = newsFeedFuture.value!
                        expect(receivedNewsFeedItems.count).to(equal(3))
                        expect(receivedNewsFeedItems[0] as? NewsArticle).to(beIdenticalTo(newsArticleA))
                        expect(receivedNewsFeedItems[1] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                        expect(receivedNewsFeedItems[2] as? NewsArticle).to(beIdenticalTo(newsArticleC))
                    }
                }

                describe("when no news items are returned") {
                    beforeEach { workerQueue.lastReceivedBlock() }

                    it("calls the completion handler with only the videos, sorted by date, on the result queue") {
                        let videoA  = TestUtils.video(NSDate(timeIntervalSince1970: 4))
                        let videoB  = TestUtils.video(NSDate(timeIntervalSince1970: 3))

                        newsArticleRepository.lastPromise.resolve([])
                        videoRepository.lastPromise.resolve([videoB, videoA])

                        expect(newsFeedFuture.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        let receivedNewsFeedItems = newsFeedFuture.value!
                        expect(receivedNewsFeedItems.count).to(equal(2))
                        expect(receivedNewsFeedItems[0] as? Video).to(beIdenticalTo(videoA))
                        expect(receivedNewsFeedItems[1] as? Video).to(beIdenticalTo(videoB))
                    }
                }

                describe("error handling") {
                    beforeEach { workerQueue.lastReceivedBlock() }

                    describe("when just the news article repo reports an error") {
                        it("calls the completion handler with the videos, on the result queue") {
                            let error = NewsArticleRepositoryError.InvalidJSON(jsonObject: "wat")
                            newsArticleRepository.lastPromise.reject(error)

                            let videoA  = TestUtils.video(NSDate(timeIntervalSince1970: 4))
                            let videoB  = TestUtils.video(NSDate(timeIntervalSince1970: 3))

                            videoRepository.lastPromise.resolve([videoB, videoA])

                            expect(newsFeedFuture.value).to(beNil())

                            resultQueue.lastReceivedBlock()

                            let receivedNewsFeedItems = newsFeedFuture.value!
                            expect(receivedNewsFeedItems.count).to(equal(2))
                            expect(receivedNewsFeedItems[0] as? Video).to(beIdenticalTo(videoA))
                            expect(receivedNewsFeedItems[1] as? Video).to(beIdenticalTo(videoB))
                        }
                    }

                    describe("when just the videos repo reports an error") {
                        it("calls the completion handler with the news articles, on the result queue") {
                            let error = VideoRepositoryError.InvalidJSON(jsonObject: "lol")
                            videoRepository.lastPromise.reject(error)

                            let newsArticleA = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 5))
                            let newsArticleB = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 4))
                            let newsArticleC = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 2))

                            newsArticleRepository.lastPromise.resolve([newsArticleC, newsArticleA, newsArticleB])

                            expect(newsFeedFuture.value).to(beNil())

                            resultQueue.lastReceivedBlock()

                            let receivedNewsFeedItems = newsFeedFuture.value!
                            expect(receivedNewsFeedItems.count).to(equal(3))
                            expect(receivedNewsFeedItems[0] as? NewsArticle).to(beIdenticalTo(newsArticleA))
                            expect(receivedNewsFeedItems[1] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                            expect(receivedNewsFeedItems[2] as? NewsArticle).to(beIdenticalTo(newsArticleC))
                        }
                    }

                    describe("when both the news article repo and videos repo reports an error") {
                        it("calls the error handler with a wrapped error, on the result queue") {
                            let newsError = NewsArticleRepositoryError.InvalidJSON(jsonObject: "wat")
                            newsArticleRepository.lastPromise.reject(newsError)

                            let videoError = VideoRepositoryError.InvalidJSON(jsonObject: "lol")
                            videoRepository.lastPromise.reject(videoError)

                            expect(newsFeedFuture.error).to(beNil())

                            resultQueue.lastReceivedBlock()

                            switch(newsFeedFuture.error!) {
                            case NewsFeedServiceError.FailedToFetchNews(let underlyingErrors):
                                expect(underlyingErrors.count).to(equal(2))

                                switch(underlyingErrors.first as! NewsArticleRepositoryError) {
                                case NewsArticleRepositoryError.InvalidJSON(let badJson):
                                    expect((badJson as! String)).to(equal("wat"))
                                default:
                                    fail("unexpected error")
                                }

                                switch(underlyingErrors.last as! VideoRepositoryError) {
                                case VideoRepositoryError.InvalidJSON(let badJson):
                                    expect((badJson as! String)).to(equal("lol"))
                                default:
                                    fail("unexpected error")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private class FakeVideoRepository: VideoRepository {
    var fetchVideosCalled: Bool = false
    var lastPromise: VideoPromise!

    func fetchVideos() -> VideoFuture {
        self.fetchVideosCalled = true
        self.lastPromise = VideoPromise()
        return self.lastPromise.future
    }
}

