import Foundation
import Quick
import Nimble
import berniesanders
import Ono
import KSDeferred

class FakeNSURLSession : NSURLSession {
    var lastURL: NSURL!
    var lastCompletionHandler : ((NSData!, NSURLResponse!, NSError!) -> Void)?
    var lastReturnedTask : FakeNSURLSessionDataTask!
    
    override init() {
        
    }
    
    override func dataTaskWithURL(url: NSURL, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask {
        self.lastURL = url
        self.lastReturnedTask = FakeNSURLSessionDataTask()
        self.lastCompletionHandler = completionHandler
        return self.lastReturnedTask
    }
}

class FakeNSURLSessionDataTask : NSURLSessionDataTask {
    var resumeCalled : Bool = false
    
    override func resume() {
        self.resumeCalled = true
    }
}

class FakeONOXMLDocumentProvider : ONOXMLDocumentProvider {
    var enableError : Bool = false
    let returnedDocument = ONOXMLDocument()
    let returnedError = NSError(domain: "errrr", code: 123, userInfo: nil)
    var lastReceivedData : NSData!
    
    override init() {
        super.init()
    }
    
    override func provideXMLDocument(data: NSData!, error: NSErrorPointer) -> ONOXMLDocument! {
        self.lastReceivedData = data
        if(self.enableError) {
            error.memory = returnedError
            return nil
        } else {
            return self.returnedDocument
        }
    }
}

class ConcreteXMLClientSpec : QuickSpec {
    var subject: ConcreteXMLClient!
    let urlSession = FakeNSURLSession()
    let onoXMLDocumentProvider = FakeONOXMLDocumentProvider()
    
    override func spec() {
        beforeEach {
            self.subject = ConcreteXMLClient(
                urlSession: self.urlSession,
                onoXMLDocumentProvider: self.onoXMLDocumentProvider
            )
        }

        describe("fetching some XML with a given URL") {
            var expectedURL = NSURL(string: "https://example.com/berrniieee")!
            var promise : KSPromise!
            
            beforeEach {
                promise = self.subject.fetchXMLDocumentWithURL(expectedURL)
            }
            
            it("creates a task from the session with the correct URL") {
                expect(self.urlSession.lastURL).to(beIdenticalTo(expectedURL))
            }
            
            it("resumes the task") {
                expect(self.urlSession.lastReturnedTask.resumeCalled).to(beTrue())
            }
            
            context("when the task completes without an error") {
                var expectedData = NSData()
                
                context("with a status code of 200") {
                    var response = NSHTTPURLResponse(URL: expectedURL, statusCode: 200, HTTPVersion: "1.1", headerFields: nil)

                    describe("parsing the xml") {
                        it("attempts to parse the received data") {
                            self.urlSession.lastCompletionHandler!(expectedData, response!, nil)
                            expect(self.onoXMLDocumentProvider.lastReceivedData).to(beIdenticalTo(expectedData))
                        }
                    }
                    
                    context("when XML parsing succeeds") {
                        it("resolves the promise with the XML document") {
                            self.urlSession.lastCompletionHandler!(expectedData, response!, nil)

                            expect(promise.fulfilled).to(beTrue())
                            var expectedValue = self.onoXMLDocumentProvider.returnedDocument
                            var value : ONOXMLDocument! = (promise.value as! ONOXMLDocument)
                            expect(value).to(beIdenticalTo(expectedValue))
                        }
                    }
                    
                    context("when XML parsing fails") {
                        it("rejects the promise with the parse error") {
                            self.onoXMLDocumentProvider.enableError = true
                            self.urlSession.lastCompletionHandler!(expectedData, response!, nil)
                            
                            expect(promise.rejected).to(beTrue())
                            expect(promise.error).to(beIdenticalTo(self.onoXMLDocumentProvider.returnedError))
                        }
                    }
                }
                
                context("with a non-200 status code") {
                    var response = NSHTTPURLResponse(URL: expectedURL, statusCode: 400, HTTPVersion: "1.1", headerFields: nil)
                    
                    it("rejects the promise with an error") {
                        self.urlSession.lastCompletionHandler!(expectedData, response!, nil)
                        
                        expect(promise.rejected).to(beTrue())
                        expect(promise.error.domain).to(equal(ConcreteXMLClient.Error.BadResponse))
                    }
                }
            }
            
            context("when the task completes with an error") {
                it("rejects the promise with the network error") {
                    var expectedError = NSError()
                    self.urlSession.lastCompletionHandler!(nil, nil, expectedError)
                    
                    expect(promise.rejected).to(beTrue())
                    expect(promise.error).to(beIdenticalTo(expectedError))
                }
            }
        }
    }
}
