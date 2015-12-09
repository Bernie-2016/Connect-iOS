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


class ConcreteNewsFeedServiceSpec: QuickSpec {
    private var subject: ConcreteNewsFeedService!
    private var newsArticleRepository: FakeNewsArticleRepository!

    override func spec() {
        describe("ConcreteNewsFeedService") {
            beforeEach {
                self.newsArticleRepository = FakeNewsArticleRepository()

                self.subject = ConcreteNewsFeedService(newsArticleRepository: self.newsArticleRepository)
            }
            describe("fetching the news feed") {
                var receivedNewsFeedItems: [NewsFeedItem]!
                var receivedError: ErrorType!

                beforeEach {
                    self.subject.fetchNewsFeed({ (newsFeedItems) -> Void in
                        receivedNewsFeedItems = newsFeedItems
                        }, error: { (error) -> Void in
                            receivedError = error
                    })
                }

                it("asks the news article repository to fetch some news articles") {
                    expect(self.newsArticleRepository.fetchNewsCalled).to(beTrue())
                }

                describe("when the news article repo returns some objects") {
                    it("calls the completion handler with those objects") {
                        let newsArticle = TestUtils.newsArticle()
                        self.newsArticleRepository.lastPromise.success([newsArticle])

                        expect(receivedNewsFeedItems).toEventuallyNot(beNil())
                        expect(receivedNewsFeedItems.count).to(equal(1))
                        expect(receivedNewsFeedItems!.first! as? NewsArticle).to(beIdenticalTo(newsArticle))

                        receivedNewsFeedItems = []

                        self.newsArticleRepository.lastPromise.success([])
                        expect(receivedNewsFeedItems.count).to(equal(0))
                    }
                }

                describe("when the news article repo reports an error") {
                    it("calls the error handler") {
                        let error = NSError(domain: "what", code: 123, userInfo: nil)
                        self.newsArticleRepository.lastPromise.failure(error)

                        expect(receivedError).toEventuallyNot(beNil())
                        expect(receivedError as NSError).to(beIdenticalTo(error))
                    }
                }
            }
        }
    }
}
