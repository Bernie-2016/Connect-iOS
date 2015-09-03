import Foundation
import Quick
import Nimble
import berniesanders
import KSDeferred

class FakeNSJSONSerializationProvider : NSJSONSerializationProvider {
    var enableError : Bool = false
    let returnedJSON = NSDictionary()
    let returnedError = NSError(domain: "errrr", code: 123, userInfo: nil)
    var lastReceivedData : NSData!
    var lastReceivedOptions : NSJSONReadingOptions!
    
    override init() {
        super.init()
    }
    
    
    override func jsonObjectWithData(data: NSData, options opt: NSJSONReadingOptions, error: NSErrorPointer) -> AnyObject? {
        self.lastReceivedData = data
        self.lastReceivedOptions = opt
        
        if(self.enableError) {
            error.memory = returnedError
            return nil
        } else {
            return self.returnedJSON
        }
    }
}

class ConcreteJSONClientSpec : QuickSpec {
    var subject: ConcreteJSONClient!
    var jsonSerializationProvider : FakeNSJSONSerializationProvider!
    let urlSession = FakeNSURLSession()
    
    override func spec() {
        beforeEach {
            self.jsonSerializationProvider = FakeNSJSONSerializationProvider()
            
            self.subject = ConcreteJSONClient(
                urlSession: self.urlSession,
                jsonSerializationProvider: self.jsonSerializationProvider
            )
        }
        
        describe("fetching some JSON with a given URL") {
            var expectedURL = NSURL(string: "https://example.com/berrniieee")!
            var promise : KSPromise!
            
            beforeEach {
                promise = self.subject.fetchJSONWithURL(expectedURL)
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
                    
                    describe("parsing the JSON") {
                        it("attempts to parse the received data") {
                            self.urlSession.lastCompletionHandler!(expectedData, response!, nil)
                            expect(self.jsonSerializationProvider.lastReceivedData).to(beIdenticalTo(expectedData))
                        }
                    }
                    
                    context("when JSON parsing succeeds") {
                        it("resolves the promise with the JSON document") {
                            self.urlSession.lastCompletionHandler!(expectedData, response!, nil)
                            
                            expect(promise.fulfilled).to(beTrue())
                            var expectedValue = self.jsonSerializationProvider.returnedJSON
                            var value : NSDictionary! = (promise.value as! NSDictionary)
                            expect(value).to(beIdenticalTo(expectedValue))
                        }
                    }
                    
                    context("when JSON parsing fails") {
                        it("rejects the promise with the parse error") {
                            self.jsonSerializationProvider.enableError = true
                            self.urlSession.lastCompletionHandler!(expectedData, response!, nil)
                            
                            expect(promise.rejected).to(beTrue())
                            expect(promise.error).to(beIdenticalTo(self.jsonSerializationProvider.returnedError))
                        }
                    }
                }
                
                context("with a non-200 status code") {
                    var response = NSHTTPURLResponse(URL: expectedURL, statusCode: 400, HTTPVersion: "1.1", headerFields: nil)
                    
                    it("rejects the promise with an error") {
                        self.urlSession.lastCompletionHandler!(expectedData, response!, nil)
                        
                        expect(promise.rejected).to(beTrue())
                        expect(promise.error.domain).to(equal(ConcreteJSONClient.Error.BadResponse))
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
