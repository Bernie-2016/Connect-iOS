import Quick
import Nimble

@testable import Movement

private class FakeNewsArticleRepository : Movement.NewsArticleRepository {
    var lastCompletionBlock: (([NewsArticle]) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchNewsCalled: Bool = false

    func fetchNewsArticles(completion: (Array<NewsArticle>) -> Void, error: (NSError) -> Void) {
        self.fetchNewsCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
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

                describe("when the news article repo reutrns some objects") {
                    it("calls the completion handler with those objects") {
                        let newsArticle = TestUtils.newsArticle()
                        self.newsArticleRepository.lastCompletionBlock!([newsArticle])

                        expect(receivedNewsFeedItems.count).to(equal(1))
                        expect(receivedNewsFeedItems!.first! as? NewsArticle).to(beIdenticalTo(newsArticle))
                    }
                }

                describe("when the news article repo reports an error") {
                    it("calls the error handler") {
                        let error = NSError(domain: "what", code: 123, userInfo: nil)
                        self.newsArticleRepository.lastErrorBlock!(error)

                        expect(receivedError as NSError).to(beIdenticalTo(error))
                    }
                }
            }
        }
    }
}
