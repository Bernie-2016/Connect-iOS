@testable import Movement
import Quick
import Nimble
import KSDeferred

class NewsArticleRepositoryFakeURLProvider: FakeURLProvider {
    override func newsFeedURL() -> NSURL! {
        return NSURL(string: "https://example.com/bernese/")
    }
}

class FakeNewsArticleDeserializer: NewsArticleDeserializer {
    var lastReceivedJSONDictionary: NSDictionary!
    let returnedNewsArticles = [NewsArticle(title: "fake news", date: NSDate(), body: "fake body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL())]

    func deserializeNewsArticles(jsonDictionary: NSDictionary) -> Array<NewsArticle> {
        self.lastReceivedJSONDictionary = jsonDictionary
        return self.returnedNewsArticles
    }
}

class ConcreteNewsArticleRepositorySpec : QuickSpec {
    var subject: ConcreteNewsArticleRepository!
    let jsonClient = FakeJSONClient()
    let urlProvider = NewsArticleRepositoryFakeURLProvider()
    let newsArticleDeserializer = FakeNewsArticleDeserializer()
    let operationQueue = FakeOperationQueue()
    var receivedNewsArticles: Array<NewsArticle>!
    var receivedError: NSError!

    override func spec() {
        self.subject = ConcreteNewsArticleRepository(
            urlProvider: self.urlProvider,
            jsonClient: self.jsonClient,
            newsArticleDeserializer: newsArticleDeserializer,
            operationQueue: self.operationQueue
        )

        describe(".fetchNewsArticles") {
            var newsArticlesPromise: KSPromise!

            beforeEach {
                newsArticlesPromise = self.subject.fetchNewsArticles()
            }

            it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                expect(self.jsonClient.deferredsByURL.count).to(equal(1))
                expect(self.jsonClient.deferredsByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))

                let expectedHTTPBodyDictionary =
                [
                    "from": 0, "size": 30,
                    "_source": ["title", "body", "excerpt", "created_at", "url", "image_url"],
                    "query": [
                        "query_string": [
                            "default_field": "article_type",
                            "query": "NOT ExternalLink OR NOT Issues"
                        ]
                    ],
                    "sort": [
                        "created_at": ["order": "desc"]
                    ]
                ]

                expect(self.jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                expect(self.jsonClient.lastMethod).to(equal("POST"))
            }

            context("when the request to the JSON client succeeds") {
                let expectedJSONDictionary = NSDictionary();

                beforeEach {
                    let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.newsFeedURL()]!

                    deferred.resolveWithValue(expectedJSONDictionary)
                }

                it("passes the json dictionary to the news item deserializer") {
                    expect(self.newsArticleDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                }

                it("calls the completion handler with the deserialized value objects on the operation queue") {
                    self.operationQueue.lastReceivedBlock()
                    let receivedNewsArticles =  newsArticlesPromise.value as! Array<NewsArticle>
                    expect(receivedNewsArticles.count).to(equal(1))
                    expect(receivedNewsArticles.first!.title).to(equal("fake news"))
                }
            }

            context("when he request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                beforeEach {
                    let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.newsFeedURL()]!

                    deferred.resolveWithValue([1,2,3])
                }

                it("calls the completion handler with an error") {
                    self.operationQueue.lastReceivedBlock()
                    expect(newsArticlesPromise.error).notTo(beNil())
                }
            }

            context("when the request to the JSON client fails") {
                it("forwards the error to the caller on the operation queue") {
                    let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.newsFeedURL()]!
                    let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                    deferred.rejectWithError(expectedError)

                    self.operationQueue.lastReceivedBlock()
                    expect(newsArticlesPromise.error).to(beIdenticalTo(expectedError))
                }
            }
        }
    }
}
