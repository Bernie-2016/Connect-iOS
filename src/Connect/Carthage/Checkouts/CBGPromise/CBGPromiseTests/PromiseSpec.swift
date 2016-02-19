import Quick
import Nimble
import CBGPromise

class PromiseSpec: QuickSpec {
    override func spec() {
        describe("Promise") {
            var subject: Promise<String, NSError>!

            beforeEach {
                subject = Promise<String, NSError>()
            }

            describe("calling the callback blocks") {
                var value: String?
                var error: NSError?

                beforeEach {
                    value = nil
                    error = nil
                }

                context("when the callbacks are registered before the promise is resolved/rejected") {
                    beforeEach {
                        subject.future.then { v in
                            value = v
                        }

                        subject.future.error { e in
                            error = e
                        }
                    }

                    it("should call the success callback when it's resolved") {
                        subject.resolve("My Special Value")

                        expect(value).to(equal("My Special Value"))
                    }

                    it("should call the error callback when it's rejected") {
                        let expectedError = NSError(domain: "My Special Domain", code: 123, userInfo: nil)

                        subject.reject(expectedError)

                        expect(error).to(equal(expectedError))
                    }
                }

                context("when the callbacks are registered after the promise is resolved/rejected") {
                    it("should call the success callback when it's resolved") {
                        subject.resolve("My Special Value")

                        subject.future.then { v in
                            value = v
                        }

                        expect(value).to(equal("My Special Value"))
                    }

                    it("should call the error callback when it's rejected") {
                        let expectedError = NSError(domain: "My Special Domain", code: 123, userInfo: nil)

                        subject.reject(expectedError)

                        subject.future.error { e in
                            error = e
                        }

                        expect(error).to(equal(expectedError))
                    }
                }
            }

            describe("accessing the value/error after the promise has been resolved/rejected") {
                it("should expose its value after it has been resolved") {
                    subject.resolve("My Special Value")

                    expect(subject.future.value).to(equal("My Special Value"))
                }

                it("should expose its error after it has been rejected") {
                    let expectedError = NSError(domain: "My Special Domain", code: 123, userInfo: nil)

                    subject.reject(expectedError)

                    expect(subject.future.error).to(equal(expectedError))
                }
            }

            describe("waiting for the promise to resolve") {
                it("should wait for a value") {
                    let queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), queue) {
                        subject.resolve("My Special Value")
                    }

                    subject.future.wait()

                    expect(subject.future.value).to(equal("My Special Value"))
                }

                it("should wait for an error") {
                    let expectedError = NSError(domain: "My Special Domain", code: 123, userInfo: nil)

                    let queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), queue) {
                        subject.reject(expectedError)
                    }

                    subject.future.wait()

                    expect(subject.future.error).to(equal(expectedError))
                }
            }
            
            describe("multiple callbacks") {
                it("calls each callback when the promise is resolved") {
                    var valA: String?
                    var valB: String?

                    subject.future.then { v in valA = v }
                    subject.future.then { v in valB = v }
                    
                    subject.resolve("My Special Value")
                    
                    expect(valA).to(equal("My Special Value"))
                    expect(valB).to(equal("My Special Value"))
                }
                
                it("calls each callback when the promise is rejected") {
                    var errorA: ErrorType?
                    var errorB: ErrorType?
                    
                    subject.future.error { e in errorA = e }
                    subject.future.error { e in errorB = e }
                    
                    let expectedError = NSError(domain: "My Special Domain", code: 123, userInfo: nil)
                    subject.reject(expectedError)
                    
                    expect(errorA).to(equal(expectedError))
                    expect(errorB).to(equal(expectedError))
                }
            }

            describe("chaining callbacks") {
                it("can start with the .then") {
                    let future = subject.future.then { _ in }
                    
                    expect(future).to(beIdenticalTo(subject.future))
                }
                
                it("can start with the .error") {
                    let future = subject.future.error { _ in }
                    
                    expect(future).to(beIdenticalTo(subject.future))
                }
                
                describe("when both callbacks are registered") {
                    var value: String?
                    var error: ErrorType?
                    
                    beforeEach {
                        subject.future
                            .then { v in value = v }
                            .error { e in error = e }
                    }
                    
                    it("calls the success callback when the promise is resolved") {
                        subject.resolve("My Special Value")
                        
                        expect(value).to(equal("My Special Value"))
                    }
                    
                    it("calls the error callback when the promise is rejected") {
                        let expectedError = NSError(domain: "My Special Domain", code: 123, userInfo: nil)
                        subject.reject(expectedError)
                        
                        expect(error).to(equal(expectedError))
                    }
                }
            }
        }
    }
}
