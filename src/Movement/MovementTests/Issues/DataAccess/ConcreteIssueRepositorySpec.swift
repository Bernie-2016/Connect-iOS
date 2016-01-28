import Quick
import Nimble

@testable import Movement

class ConcreteIssueRepositorySpec : QuickSpec {
    var subject: ConcreteIssueRepository!
    var jsonClient: FakeJSONClient!
    private let urlProvider = IssueRepositoryFakeURLProvider()
    private var issueDeserializer: FakeIssueDeserializer!

    override func spec() {
        describe("ConcreteIssueRepository") {
            beforeEach() {
                self.jsonClient = FakeJSONClient()
                self.issueDeserializer = FakeIssueDeserializer()

                self.subject = ConcreteIssueRepository(
                    urlProvider: self.urlProvider,
                    jsonClient: self.jsonClient,
                    issueDeserializer: self.issueDeserializer
                )
            }

            describe(".fetchIssues") {
                var issuesFuture: IssuesFuture!

                beforeEach {
                    issuesFuture = self.subject.fetchIssues()
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
                            "timestamp_publish": ["order": "desc", "ignore_unmapped": true]
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

                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the JSON document to the issue deserializer") {
                        expect(self.issueDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        expect(issuesFuture.value!.count).to(equal(1))
                        expect(issuesFuture.value!.first!).to(beIdenticalTo(expectedIssues.first!))
                    }
                }

                context("when he request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    it("calls the completion handler with an error") {
                        let promise = self.jsonClient.promisesByURL[self.urlProvider.issuesFeedURL()]!

                        let badObj = [1,2,3]
                        promise.resolve(badObj)

                        switch(issuesFuture.error!) {
                        case .InvalidJSON(let jsonObject):
                            expect(jsonObject as? [Int]).to(equal(badObj))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = self.jsonClient.promisesByURL[self.urlProvider.issuesFeedURL()]!
                        let expectedUnderlyingError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        let jsonClientError = JSONClientError.NetworkError(error: expectedUnderlyingError)

                        promise.reject(jsonClientError)

                        switch(issuesFuture.error!) {
                        case .ErrorInJSONClient(let jsonClientError):
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
