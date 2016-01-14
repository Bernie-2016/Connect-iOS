@testable import Movement
import Quick
import Nimble
import CBGPromise

private class NewsArticleRepositoryFakeURLProvider: FakeURLProvider {
    override func newsFeedURL() -> NSURL {
        return NSURL(string: "https://example.com/bernese/")!
    }
}

private class FakeNewsArticleDeserializer: NewsArticleDeserializer {
    var lastReceivedJSONDictionary: NSDictionary!
    var returnedNewsArticles = [NewsArticle(title: "fake news", date: NSDate(), body: "fake body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL())]

    func deserializeNewsArticles(jsonDictionary: NSDictionary) -> Array<NewsArticle> {
        self.lastReceivedJSONDictionary = jsonDictionary
        return self.returnedNewsArticles
    }
}

class ConcreteNewsArticleRepositorySpec: QuickSpec {
    override func spec() {
        describe("ConcreteNewsArticleRepository") {
            var subject: ConcreteNewsArticleRepository!
            var jsonClient: FakeJSONClient!
            let urlProvider = NewsArticleRepositoryFakeURLProvider()
            var newsArticleDeserializer: FakeNewsArticleDeserializer!

            beforeEach {
                jsonClient = FakeJSONClient()
                newsArticleDeserializer = FakeNewsArticleDeserializer()

                subject = ConcreteNewsArticleRepository(
                    urlProvider: urlProvider,
                    jsonClient: jsonClient,
                    newsArticleDeserializer: newsArticleDeserializer
                )
            }

            describe("fetching news articles") {
                var newsArticlesFuture: NewsArticlesFuture!

                beforeEach {
                    newsArticlesFuture = subject.fetchNewsArticles()
                }

                it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                    expect(jsonClient.promisesByURL.count).to(equal(1))
                    expect(jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))

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

                    expect(jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                    expect(jsonClient.lastMethod).to(equal("POST"))
                }

                context("when the request to the JSON client succeeds") {
                    let expectedJSONDictionary = NSDictionary();

                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!

                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the news item deserializer") {
                        expect(newsArticleDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        let receivedNewsArticles =  newsArticlesFuture.value!
                        expect(receivedNewsArticles.count).to(equal(1))
                        expect(receivedNewsArticles.first!.title).to(equal("fake news"))
                    }
                }

                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!

                        promise.resolve([1,2,3])
                    }

                    it("calls the completion handler with an error") {
                        expect(newsArticlesFuture.error).notTo(beNil())
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!
                        let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        promise.reject(expectedError)

                        expect(newsArticlesFuture.error).to(beIdenticalTo(expectedError))
                    }
                }
            }

            describe("fetching a given news article") {
                var newsArticleFuture: NewsArticleFuture!

                beforeEach {
                    newsArticleFuture = subject.fetchNewsArticle("some-identifier")
                }

                it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                    expect(jsonClient.promisesByURL.count).to(equal(1))
                    expect(jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))

                    let expectedHTTPBodyDictionary =
                    [
                        "from": 0, "size": 1,
                        "_source": ["title", "body", "excerpt", "created_at", "url", "image_url"],
                        "filter": [
                            "term": [
                                "_id": "some-identifier",
                            ]
                        ],
                        "sort": [
                            "created_at": ["order": "desc"]
                        ]
                    ]

                    expect(jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                    expect(jsonClient.lastMethod).to(equal("POST"))
                }

                context("when the request to the JSON client succeeds with a news article") {
                    let expectedJSONDictionary = NSDictionary();

                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!

                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the news item deserializer") {
                        expect(newsArticleDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        let receivedNewsArticle =  newsArticleFuture.value!
                        expect(receivedNewsArticle.title).to(equal("fake news"))
                    }
                }

                context("when the request to the JSON client succeeds without a news article") {
                    let expectedJSONDictionary = NSDictionary();

                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!
                        newsArticleDeserializer.returnedNewsArticles = []
                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the news item deserializer") {
                        expect(newsArticleDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with an error") {
                        expect(newsArticleFuture.error).notTo(beNil())
                    }
                }


                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!

                        promise.resolve([1,2,3])
                    }

                    it("calls the completion handler with an error") {
                        expect(newsArticleFuture.error).notTo(beNil())
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!
                        let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        promise.reject(expectedError)

                        expect(newsArticleFuture.error).to(beIdenticalTo(expectedError))
                    }
                }
            }
        }
    }
}
