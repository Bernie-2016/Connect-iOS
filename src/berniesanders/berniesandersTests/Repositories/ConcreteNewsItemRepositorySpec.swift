@testable import berniesanders
import Quick
import Nimble
import KSDeferred

class NewsItemRepositoryFakeURLProvider: FakeURLProvider {
    override func newsFeedURL() -> NSURL! {
        return NSURL(string: "https://example.com/bernese/")
    }
}

class FakeNewsItemDeserializer: NewsItemDeserializer {
    var lastReceivedJSONDictionary: NSDictionary!
    let returnedNewsItems = [NewsItem(title: "fake news", date: NSDate(), body: "fake body", imageURL: NSURL(), URL: NSURL())]

    func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem> {
        self.lastReceivedJSONDictionary = jsonDictionary
        return self.returnedNewsItems
    }
}

class ConcreteNewsItemRepositorySpec : QuickSpec {
    var subject: ConcreteNewsItemRepository!
    let jsonClient = FakeJSONClient()
    let urlProvider = NewsItemRepositoryFakeURLProvider()
    let newsItemDeserializer = FakeNewsItemDeserializer()
    let operationQueue = FakeOperationQueue()
    var receivedNewsItems: Array<NewsItem>!
    var receivedError: NSError!

    override func spec() {
        self.subject = ConcreteNewsItemRepository(
            urlProvider: self.urlProvider,
            jsonClient: self.jsonClient,
            newsItemDeserializer: newsItemDeserializer,
            operationQueue: self.operationQueue
        )

        describe(".fetchNewsItems") {
            beforeEach {
                self.subject.fetchNewsItems({ (newsItems) -> Void in
                    self.receivedNewsItems = newsItems
                    }, error: { (error) -> Void in
                        self.receivedError = error
                })
            }

            it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                expect(self.jsonClient.deferredsByURL.count).to(equal(1))
                expect(self.jsonClient.deferredsByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))

                let expectedHTTPBodyDictionary =
                [
                    "from": 0, "size": 30,
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
                _ = self.newsItemDeserializer.returnedNewsItems

                beforeEach {
                    let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.newsFeedURL()]!

                    deferred.resolveWithValue(expectedJSONDictionary)
                }

                it("passes the json dictionary to the news item deserializer") {
                    expect(self.newsItemDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                }

                it("calls the completion handler with the deserialized value objects on the operation queue") {
                    self.operationQueue.lastReceivedBlock()
                    expect(self.receivedNewsItems.count).to(equal(1))
                    expect(self.receivedNewsItems.first!.title).to(equal("fake news"))
                }
            }

            context("when the request to the JSON client fails") {
                it("forwards the error to the caller on the operation queue") {
                    let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.newsFeedURL()]!
                    let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                    deferred.rejectWithError(expectedError)

                    self.operationQueue.lastReceivedBlock()
                    expect(self.receivedError).to(beIdenticalTo(expectedError))
                }
            }
        }
    }
}
