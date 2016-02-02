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
                        "_source": ["title", "body", "excerpt", "timestamp_publish", "url", "image_url"],
                        "query": [
                            "query_string": [
                                "default_field": "article_type",
                                "query": "PressRelease OR DemocracyDaily"
                            ]
                        ],
                        "sort": [
                            "timestamp_publish": ["order": "desc", "ignore_unmapped": true]
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

                context("when the request to the JSON client succeeds but does not resolve with a JSON dictionary") {
                    it("calls the completion handler with an error") {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!

                        let badObj = [1,2,3]
                        promise.resolve(badObj)

                        switch(newsArticlesFuture.error!) {
                        case NewsArticleRepositoryError.InvalidJSON(let jsonObject):
                            expect(jsonObject as? [Int]).to(equal(badObj))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!
                        let expectedUnderlyingError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        let jsonClientError = JSONClientError.NetworkError(error: expectedUnderlyingError)

                        promise.reject(jsonClientError)

                        switch(newsArticlesFuture.error!) {
                        case NewsArticleRepositoryError.ErrorInJSONClient(let jsonClientError):
                            switch(jsonClientError) {
                            case JSONClientError.NetworkError(let underlyingError):
                                expect(underlyingError).to(beIdenticalTo(expectedUnderlyingError))
                            default:
                                fail("unexpected error type")
                            }
                        default:
                            fail("unexpected error type")
                        }
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
                        "_source": ["title", "body", "excerpt", "timestamp_publish", "url", "image_url"],
                        "filter": [
                            "term": [
                                "_id": "some-identifier",
                            ]
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
                        switch(newsArticleFuture.error!) {
                        case NewsArticleRepositoryError.NoMatchingNewsArticle(let identifier):
                            expect(identifier).to(equal("some-identifier"))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }


                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    it("calls the completion handler with an error") {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!

                        let badObj = [1,2,3]
                        promise.resolve(badObj)

                        switch(newsArticleFuture.error!) {
                        case NewsArticleRepositoryError.InvalidJSON(let jsonObject):
                            expect(jsonObject as? [Int]).to(equal(badObj))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!
                        let expectedUnderlyingError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        let jsonClientError = JSONClientError.NetworkError(error: expectedUnderlyingError)

                        promise.reject(jsonClientError)

                        switch(newsArticleFuture.error!) {
                        case NewsArticleRepositoryError.ErrorInJSONClient(let jsonClientError):
                            switch(jsonClientError) {
                            case JSONClientError.NetworkError(let underlyingError):
                                expect(underlyingError).to(beIdenticalTo(expectedUnderlyingError))
                            default:
                                fail("unexpected error type")
                            }
                        default:
                            fail("unexpected error type")
                        }
                    }
                }
            }
        }
    }
}
