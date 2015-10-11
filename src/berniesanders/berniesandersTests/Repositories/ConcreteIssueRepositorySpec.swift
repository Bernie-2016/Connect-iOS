import berniesanders
import Quick
import Nimble
import KSDeferred

class IssueRepositoryFakeURLProvider: FakeURLProvider {
    override func issuesFeedURL() -> NSURL! {
        return NSURL(string: "https://example.com/bernese/")
    }
}

class FakeIssueDeserializer: IssueDeserializer {
    var lastReceivedJSONDictionary: NSDictionary!
    let returnedIssues = [TestUtils.issue()]
    
    func deserializeIssues(jsonDictionary: NSDictionary) -> Array<Issue> {
        self.lastReceivedJSONDictionary = jsonDictionary
        return self.returnedIssues
    }
}

class ConcreteIssueRepositorySpec : QuickSpec {
    var subject: ConcreteIssueRepository!
    let jsonClient = FakeJSONClient()
    let urlProvider = IssueRepositoryFakeURLProvider()
    let issueDeserializer = FakeIssueDeserializer()
    let operationQueue = FakeOperationQueue()
    var receivedIssues: Array<Issue>!
    var receivedError: NSError!

    override func spec() {
        self.subject = ConcreteIssueRepository(
            urlProvider: self.urlProvider,
            jsonClient: self.jsonClient,
            issueDeserializer: issueDeserializer,
            operationQueue: self.operationQueue
        )
    
        describe(".fetchIssues") {
            beforeEach {
                self.subject.fetchIssues({ (issues) -> Void in
                    self.receivedIssues = issues
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
                let expectedIssues = self.issueDeserializer.returnedIssues
                
                beforeEach {
                    let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.issuesFeedURL()]!

                    deferred.resolveWithValue(expectedJSONDictionary)
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
            
            context("when the request to the JSON client fails") {
                it("forwards the error to the caller on the operation queue") {
                    let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.issuesFeedURL()]!
                    let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                    deferred.rejectWithError(expectedError)
                    
                    self.operationQueue.lastReceivedBlock()
                    expect(self.receivedError).to(beIdenticalTo(expectedError))
                }
            }
        }
    }
}