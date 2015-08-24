import berniesanders
import Quick
import Nimble
import KSDeferred
import Ono

class IssueRepositoryFakeURLProvider: FakeURLProvider {
    override func issuesFeedURL() -> NSURL! {
        return NSURL(string: "https://example.com/bernese/")
    }
}

class FakeXMLClient: XMLClient {
    private (set) var deferredsByURL = [NSURL: KSDeferred]()
    
    func fetchXMLDocumentWithURL(url: NSURL) -> KSPromise {
        var deferred =  KSDeferred.defer()
        self.deferredsByURL[url] = deferred
        return deferred.promise
    }
}

class FakeIssueDeserializer: IssueDeserializer {
    var lastReceivedXMLDocument: ONOXMLDocument!
    var returnedIssues = [Issue(title: "fake issue")]
    
    func deserializeIssues(xmlDocument: ONOXMLDocument) -> Array<Issue> {
        self.lastReceivedXMLDocument = xmlDocument
        return self.returnedIssues
    }
}


class ConcreteIssueRepositorySpec : QuickSpec {
    var subject: ConcreteIssueRepository!
    let xmlClient = FakeXMLClient()
    let urlProvider = IssueRepositoryFakeURLProvider()
    let issueDeserializer = FakeIssueDeserializer()
    var receivedIssues: Array<Issue>!
    var receivedError: NSError!

    override func spec() {
        self.subject = ConcreteIssueRepository(
            urlProvider: self.urlProvider,
            xmlClient: self.xmlClient,
            issueDeserializer: issueDeserializer
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
                expect(self.xmlClient.deferredsByURL.count).to(equal(1))
                expect(self.xmlClient.deferredsByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))
            }
            
            context("when the request to the XML client succeeds") {
                var expectedXMLDocument = ONOXMLDocument()
                var expectedIssues = self.issueDeserializer.returnedIssues
                
                beforeEach {
                    var deferred: KSDeferred = self.xmlClient.deferredsByURL[self.urlProvider.issuesFeedURL()]!

                    deferred.resolveWithValue(expectedXMLDocument)
                }
                
                it("passes the xml document to the issue deserialzier") {
                    expect(self.issueDeserializer.lastReceivedXMLDocument).to(beIdenticalTo(expectedXMLDocument))
                }
                
                it("calls the completion handler with the deserialized value objects") {
                    expect(self.receivedIssues.count).to(equal(1))
                    expect(self.receivedIssues.first!.title).to(equal("fake issue"))
                }
            }
            
            context("when the request to the XML client fails") {
                it("forwards the error to the caller") {
                    var deferred: KSDeferred = self.xmlClient.deferredsByURL[self.urlProvider.issuesFeedURL()]!
                    var expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                    deferred.rejectWithError(expectedError)
                    
                    expect(self.receivedError).to(beIdenticalTo(expectedError))
                }
            }
        }
    }
}