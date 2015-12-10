@testable import Movement
import Quick
import Nimble

private class IssueRepositoryFakeURLProvider: FakeURLProvider {
    override func issuesFeedURL() -> NSURL {
        return NSURL(string: "https://example.com/bernese/")!
    }
}

private class FakeIssueDeserializer: IssueDeserializer {
    var lastReceivedJSONDictionary: NSDictionary!
    let returnedIssues = [TestUtils.issue()]

    func deserializeIssues(jsonDictionary: NSDictionary) -> Array<Issue> {
        self.lastReceivedJSONDictionary = jsonDictionary
        return self.returnedIssues
    }
}

class ConcreteIssueRepositorySpec : QuickSpec {
    var subject: ConcreteIssueRepository!
    var jsonClient: FakeJSONClient!
    private let urlProvider = IssueRepositoryFakeURLProvider()
    private var issueDeserializer: FakeIssueDeserializer!
    var operationQueue: FakeOperationQueue!
    var receivedIssues: Array<Issue>!
    var receivedError: NSError!

    override func spec() {
        xdescribe("ConcreteIssueRepository") {
            beforeEach() {
                self.jsonClient = FakeJSONClient()
                self.issueDeserializer = FakeIssueDeserializer()
                self.operationQueue = FakeOperationQueue()

                self.subject = ConcreteIssueRepository(
                    urlProvider: self.urlProvider,
                    jsonClient: self.jsonClient,
                    issueDeserializer: self.issueDeserializer,
                    operationQueue: self.operationQueue
                )
            }

            describe(".fetchIssues") {
                beforeEach {
                    self.subject.fetchIssues({ (issues) -> Void in
                        self.receivedIssues = issues
                        }, error: { (error) -> Void in
                            self.receivedError = error
                    })
                }

                it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                    expect(self.jsonClient.promisesByURL.count).to(equal(1))
                    expect(self.jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))

                    let expectedHTTPBodyDictionary =
                    [
                        "from": 0, "size": 30,
                        "_source": ["title", "body", "url", "image_url"],
                        "query": [
                            "query_string": [
                                "default_field": "article_type",
                                "query": "Issues"
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
                    let expectedJSONDictionary = NSDictionary()
                    var expectedIssues: Array<Issue>!

                    beforeEach {
                        expectedIssues = self.issueDeserializer.returnedIssues
                        let promise = self.jsonClient.promisesByURL[self.urlProvider.issuesFeedURL()]!

                        promise.success(expectedJSONDictionary)
                        expect(self.operationQueue.lastReceivedBlock).toEventuallyNot(beNil())
                    }

                    it("passes the JSON document to the issue deserializer") {
                        expect(self.issueDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects on the operation queue") {
                        self.operationQueue.lastReceivedBlock()
                        expect(self.receivedIssues.count).to(equal(1))
                        expect(self.receivedIssues.first!).to(beIdenticalTo(expectedIssues.first!))
                    }
                }

                context("when he request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    beforeEach {
                        let promise = self.jsonClient.promisesByURL[self.urlProvider.issuesFeedURL()]!

                        promise.success([1,2,3])
                        expect(self.operationQueue.lastReceivedBlock).toEventuallyNot(beNil())
                    }

                    it("calls the completion handler with an error") {
                        self.operationQueue.lastReceivedBlock()
                        expect(self.receivedError).notTo(beNil())
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller on the operation queue") {
                        let promise = self.jsonClient.promisesByURL[self.urlProvider.issuesFeedURL()]!
                        let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        promise.failure(expectedError)
                        expect(self.operationQueue.lastReceivedBlock).toEventuallyNot(beNil())

                        self.operationQueue.lastReceivedBlock()
                        expect(self.receivedError).to(beIdenticalTo(expectedError))
                    }
                }
            }
        }
    }
}
