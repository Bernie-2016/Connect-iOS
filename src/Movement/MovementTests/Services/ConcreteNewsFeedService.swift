import Quick
import Nimble
import KSDeferred

@testable import Movement

private class FakeNewsArticleRepository : Movement.NewsArticleRepository {
    var fetchNewsCalled: Bool = false
    var lastDeferred: KSDeferred!

    func fetchNewsArticles() -> KSPromise {
        self.fetchNewsCalled = true
        self.lastDeferred = KSDeferred()
        return self.lastDeferred.promise
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
                        self.newsArticleRepository.lastDeferred.resolveWithValue([newsArticle])

                        expect(receivedNewsFeedItems.count).to(equal(1))
                        expect(receivedNewsFeedItems!.first! as? NewsArticle).to(beIdenticalTo(newsArticle))

                        receivedNewsFeedItems = []

                        self.newsArticleRepository.lastDeferred.resolveWithValue([])
                        expect(receivedNewsFeedItems.count).to(equal(0))
                    }
                }

                describe("when the news article repo returns some unexpected objects") {
                    // TODO: figure out if we can use KSDeferred's generics support to catch this at compile time
                    it("calls the error handler") {
                        self.newsArticleRepository.lastDeferred.resolveWithValue([NSObject()])

                        expect(receivedError).notTo(beNil())
                    }
                }

                describe("when the news article repo reports an error") {
                    it("calls the error handler") {
                        let error = NSError(domain: "what", code: 123, userInfo: nil)
                        self.newsArticleRepository.lastDeferred.rejectWithError(error)

                        expect(receivedError as NSError).to(beIdenticalTo(error))
                    }
                }
            }
        }
    }
}
