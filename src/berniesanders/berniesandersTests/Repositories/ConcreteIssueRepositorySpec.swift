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
    let returnedIssues = [Issue(title: "fake issue")]
    
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
            
            it("makes a single request to the XML Client with the correct URL") {
                expect(self.jsonClient.deferredsByURL.count).to(equal(1))
                expect(self.jsonClient.deferredsByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))
            }
            
            context("when the request to the JSON client succeeds") {
                var expectedJSONDictionary = NSDictionary()
                var expectedIssues = self.issueDeserializer.returnedIssues
                
                beforeEach {
                    var deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.issuesFeedURL()]!

                    deferred.resolveWithValue(expectedJSONDictionary)
                }
                
                it("passes the xml document to the issue deserialzier") {
                    expect(self.issueDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                }
                
                it("calls the completion handler with the deserialized value objects on the operation queue") {
                    self.operationQueue.lastReceivedBlock()
                    expect(self.receivedIssues.count).to(equal(1))
                    expect(self.receivedIssues.first!.title).to(equal("fake issue"))
                }
            }
            
            context("when the request to the JSON client fails") {
                it("forwards the error to the caller on the operation queue") {
                    var deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.issuesFeedURL()]!
                    var expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                    deferred.rejectWithError(expectedError)
                    
                    self.operationQueue.lastReceivedBlock()
                    expect(self.receivedError).to(beIdenticalTo(expectedError))
                }
            }
        }
    }
}