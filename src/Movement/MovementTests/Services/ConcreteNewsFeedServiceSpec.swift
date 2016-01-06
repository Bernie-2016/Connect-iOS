import Quick
import Nimble
import BrightFutures

@testable import Movement

private class FakeNewsArticleRepository: NewsArticleRepository {
    var fetchNewsCalled: Bool = false
    var lastPromise: Promise<Array<NewsArticle>, NSError>!

    func fetchNewsArticles() -> Future<Array<NewsArticle>, NSError> {
        self.fetchNewsCalled = true
        self.lastPromise = Promise<Array<NewsArticle>, NSError>()
        return self.lastPromise.future
    }
}

private class FakeVideoRepository: VideoRepository {
    var fetchVideosCalled: Bool = false
    var lastPromise: Promise<Array<Video>, NSError>!

    func fetchVideos() -> Future<Array<Video>, NSError> {
        self.fetchVideosCalled = true
        self.lastPromise = Promise<Array<Video>, NSError>()
        return self.lastPromise.future
    }
}


class ConcreteNewsFeedServiceSpec: QuickSpec {
    override func spec() {
        describe("ConcreteNewsFeedService") {
            var subject: ConcreteNewsFeedService!
            var newsArticleRepository: FakeNewsArticleRepository!
            var videoRepository: FakeVideoRepository!

            beforeEach {
                newsArticleRepository = FakeNewsArticleRepository()
                videoRepository = FakeVideoRepository()

                subject = ConcreteNewsFeedService(
                    newsArticleRepository: newsArticleRepository,
                    videoRepository: videoRepository
                )
            }
            describe("fetching the news feed") {
                var receivedNewsFeedItems: [NewsFeedItem]!
                var receivedError: ErrorType!

                beforeEach {
                    subject.fetchNewsFeed({ (newsFeedItems) -> Void in
                        receivedNewsFeedItems = newsFeedItems
                        }, error: { (error) -> Void in
                            receivedError = error
                    })
                }

                it("asks the news article repository to fetch some news articles") {
                    expect(newsArticleRepository.fetchNewsCalled).to(beTrue())
                }

                it("asks the video repository to fetch some videos") {
                    expect(videoRepository.fetchVideosCalled).to(beTrue())
                }

                describe("when both the news article repo and video repo returns some objects") {
                    it("calls the completion handler with the news feed items, with the most recent video first and the rest of the news feed items sorted by date") {
                        let newsArticleA = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 5))
                        let newsArticleB = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 4))
                        let newsArticleC = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 2))

                        let videoA  = TestUtils.video(NSDate(timeIntervalSince1970: 4))
                        let videoB  = TestUtils.video(NSDate(timeIntervalSince1970: 3))

                        newsArticleRepository.lastPromise.success([newsArticleC, newsArticleA, newsArticleB])
                        videoRepository.lastPromise.success([videoB, videoA])

                        expect(receivedNewsFeedItems).toEventuallyNot(beNil())
                        expect(receivedNewsFeedItems.count).to(equal(5))
                        expect(receivedNewsFeedItems![0] as? Video).to(beIdenticalTo(videoA))
                        expect(receivedNewsFeedItems![1] as? NewsArticle).to(beIdenticalTo(newsArticleA))
                        expect(receivedNewsFeedItems![2] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                        expect(receivedNewsFeedItems![3] as? Video).to(beIdenticalTo(videoB))
                        expect(receivedNewsFeedItems![4] as? NewsArticle).to(beIdenticalTo(newsArticleC))
                    }
                }

                describe("when no videos are returned") {
                    it("calls the completion handler with only the news articles, sorted by date") {
                        let newsArticleA = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 5))
                        let newsArticleB = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 4))
                        let newsArticleC = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 2))

                        newsArticleRepository.lastPromise.success([newsArticleC, newsArticleA, newsArticleB])
                        videoRepository.lastPromise.success([])

                        expect(receivedNewsFeedItems).toEventuallyNot(beNil())
                        expect(receivedNewsFeedItems.count).to(equal(3))
                        expect(receivedNewsFeedItems![0] as? NewsArticle).to(beIdenticalTo(newsArticleA))
                        expect(receivedNewsFeedItems![1] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                        expect(receivedNewsFeedItems![2] as? NewsArticle).to(beIdenticalTo(newsArticleC))
                    }
                }

                describe("when no news items are returned") {
                    it("calls the completion handler with only the videos, sorted by date") {
                        let videoA  = TestUtils.video(NSDate(timeIntervalSince1970: 4))
                        let videoB  = TestUtils.video(NSDate(timeIntervalSince1970: 3))

                        newsArticleRepository.lastPromise.success([])
                        videoRepository.lastPromise.success([videoB, videoA])

                        expect(receivedNewsFeedItems).toEventuallyNot(beNil())
                        expect(receivedNewsFeedItems.count).to(equal(2))
                        expect(receivedNewsFeedItems![0] as? Video).to(beIdenticalTo(videoA))
                        expect(receivedNewsFeedItems![1] as? Video).to(beIdenticalTo(videoB))
                    }
                }

                describe("error handling") {
                    describe("when just the news article repo reports an error") {
                        it("calls the completion handler with the videos") {
                            let error = NSError(domain: "what", code: 123, userInfo: nil)
                            newsArticleRepository.lastPromise.failure(error)

                            let videoA  = TestUtils.video(NSDate(timeIntervalSince1970: 4))
                            let videoB  = TestUtils.video(NSDate(timeIntervalSince1970: 3))

                            videoRepository.lastPromise.success([videoB, videoA])

                            expect(receivedNewsFeedItems).toEventuallyNot(beNil())
                            expect(receivedNewsFeedItems.count).to(equal(2))
                            expect(receivedNewsFeedItems![0] as? Video).to(beIdenticalTo(videoA))
                            expect(receivedNewsFeedItems![1] as? Video).to(beIdenticalTo(videoB))
                        }
                    }

                    describe("when just the videos repo reports an error") {
                        it("calls the completion handler with the news artiles") {
                            let error = NSError(domain: "what", code: 123, userInfo: nil)
                            videoRepository.lastPromise.failure(error)

                            let newsArticleA = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 5))
                            let newsArticleB = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 4))
                            let newsArticleC = TestUtils.newsArticle(NSDate(timeIntervalSince1970: 2))

                            newsArticleRepository.lastPromise.success([newsArticleC, newsArticleA, newsArticleB])

                            expect(receivedNewsFeedItems).toEventuallyNot(beNil())
                            expect(receivedNewsFeedItems.count).to(equal(3))
                            expect(receivedNewsFeedItems![0] as? NewsArticle).to(beIdenticalTo(newsArticleA))
                            expect(receivedNewsFeedItems![1] as? NewsArticle).to(beIdenticalTo(newsArticleB))
                            expect(receivedNewsFeedItems![2] as? NewsArticle).to(beIdenticalTo(newsArticleC))
                        }
                    }

                    describe("when both the news article repo and videos repo reports an error") {
                        it("calls the error handler with a wrapped error") {
                            let newsError = NSError(domain: "news error", code: 123, userInfo: nil)
                            newsArticleRepository.lastPromise.failure(newsError)

                            let videoError = NSError(domain: "video error", code: 123, userInfo: nil)
                            videoRepository.lastPromise.failure(videoError)

                            expect(receivedError).toEventuallyNot(beNil())
                            expect((receivedError as NSError).userInfo["UnderlyingErrors"] as? Array).to(equal([newsError, videoError]))
                        }
                    }
                }
            }
        }
    }
}
