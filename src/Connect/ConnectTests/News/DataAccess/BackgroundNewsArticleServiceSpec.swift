import Quick
import Nimble

@testable import Connect

class BackgroundNewsArticleServiceSpec: QuickSpec {
    override func spec() {
        describe("BackgroundNewsArticleService") {
            var subject: NewsArticleService!
            var newsArticleRepository: FakeNewsArticleRepository!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!


            beforeEach {
                newsArticleRepository = FakeNewsArticleRepository()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = BackgroundNewsArticleService(
                    newsArticleRepository: newsArticleRepository,
                    workerQueue: workerQueue,
                    resultQueue: resultQueue
                )
            }

            describe("fetching a particular news article") {
                it("makes a request to the news article repository on the worker queue") {
                    subject.fetchNewsArticle("some-identifier")

                    expect(newsArticleRepository.lastFetchedNewsArticleIdentifier).to(beNil())

                    workerQueue.lastReceivedBlock()

                    expect(newsArticleRepository.lastFetchedNewsArticleIdentifier).to(equal("some-identifier"))
                }

                context("when the repository resolves its promise with a news article") {
                    it("resolves its promise with the news article on the result queue") {
                        let expectedNewsArticle = TestUtils.newsArticle()

                        let future = subject.fetchNewsArticle("some-identifier")
                        workerQueue.lastReceivedBlock()

                        newsArticleRepository.lastArticlePromise.resolve(expectedNewsArticle)

                        expect(future.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.value).to(beIdenticalTo(expectedNewsArticle))
                    }
                }

                context("when the repository rejects its promise with an error") {
                    it("rejects its promise with the error on the result queue") {
                        let expectedError = NewsArticleRepositoryError.NoMatchingNewsArticle(identifier: "wat")

                        let future = subject.fetchNewsArticle("some-identifier")
                        workerQueue.lastReceivedBlock()

                        newsArticleRepository.lastArticlePromise.reject(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        switch(future.error!) {
                        case .NoMatchingNewsArticle(let identifier):
                            expect(identifier).to(equal("wat"))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }
            }
        }
    }
}
