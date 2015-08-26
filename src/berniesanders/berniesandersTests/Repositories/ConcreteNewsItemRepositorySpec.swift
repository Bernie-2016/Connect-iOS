import berniesanders
import Quick
import Nimble
import KSDeferred
import Ono

class NewsItemRepositoryFakeURLProvider: FakeURLProvider {
    override func newsFeedURL() -> NSURL! {
        return NSURL(string: "https://example.com/bernese/")
    }
}

class FakeNewsItemDeserializer: NewsItemDeserializer {
    var lastReceivedXMLDocument: ONOXMLDocument!
    var returnedNewsItems = [NewsItem(title: "fake news", date: NSDate())]
    
    func deserializeNewsItems(xmlDocument: ONOXMLDocument) -> Array<NewsItem> {
        self.lastReceivedXMLDocument = xmlDocument
        return self.returnedNewsItems
    }
}

class ConcreteNewsItemRepositorySpec : QuickSpec {
    var subject: ConcreteNewsItemRepository!
    let xmlClient = FakeXMLClient()
    let urlProvider = NewsItemRepositoryFakeURLProvider()
    let newsItemDeserializer = FakeNewsItemDeserializer()
    let operationQueue = FakeOperationQueue()
    var receivedNewsItems: Array<NewsItem>!
    var receivedError: NSError!
    
    override func spec() {
        self.subject = ConcreteNewsItemRepository(
            urlProvider: self.urlProvider,
            xmlClient: self.xmlClient,
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
            
            it("makes a single request to the XML Client with the correct URL") {
                expect(self.xmlClient.deferredsByURL.count).to(equal(1))
                expect(self.xmlClient.deferredsByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))
            }
            
            context("when the request to the XML client succeeds") {
                var expectedXMLDocument = ONOXMLDocument()
                var expectedNewsItems = self.newsItemDeserializer.returnedNewsItems
                
                beforeEach {
                    var deferred: KSDeferred = self.xmlClient.deferredsByURL[self.urlProvider.newsFeedURL()]!
                    
                    deferred.resolveWithValue(expectedXMLDocument)
                }
                
                it("passes the xml document to the news item deserialzier") {
                    expect(self.newsItemDeserializer.lastReceivedXMLDocument).to(beIdenticalTo(expectedXMLDocument))
                }
                
                it("calls the completion handler with the deserialized value objects on the operation queue") {
                    self.operationQueue.lastReceivedBlock()
                    expect(self.receivedNewsItems.count).to(equal(1))
                    expect(self.receivedNewsItems.first!.title).to(equal("fake news"))
                }
            }
            
            context("when the request to the XML client fails") {
                it("forwards the error to the caller on the operation queue") {
                    var deferred: KSDeferred = self.xmlClient.deferredsByURL[self.urlProvider.newsFeedURL()]!
                    var expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                    deferred.rejectWithError(expectedError)
                    
                    self.operationQueue.lastReceivedBlock()
                    expect(self.receivedError).to(beIdenticalTo(expectedError))
                }
            }
        }
    }
}