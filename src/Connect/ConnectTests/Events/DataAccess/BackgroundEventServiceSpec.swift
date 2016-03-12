import Quick
import Nimble
import CoreLocation

@testable import Connect

class BackgroundEventServiceSpec: QuickSpec {
    override func spec() {
        describe("BackgroundEventService") {
            var subject: EventService!
            var eventRepository: MockEventRepository!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!


            beforeEach {
                eventRepository = MockEventRepository()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = BackgroundEventService(eventRepository: eventRepository, workerQueue: workerQueue, resultQueue: resultQueue)
            }

            describe("fetching events") {
                it("makes a request to the event repository on the worker queue") {
                    subject.fetchEventsWithZipCode("12345", radiusMiles: 42.0)

                    expect(eventRepository.lastReceivedZipCode).to(beNil())

                    workerQueue.lastReceivedBlock()

                    expect(eventRepository.lastReceivedZipCode).to(equal("12345"))
                    expect(eventRepository.lastReceivedRadiusMiles).to(equal(42.0))
                }

                context("when the event repo calls the completion handler") {
                    it("resolves the promise on the result queue with the search result") {
                        let future = subject.fetchEventsWithZipCode("12345", radiusMiles: 42.0)
                        workerQueue.lastReceivedBlock()

                        let expectedSearchResult = EventSearchResult(events: [])
                        eventRepository.lastReturnedPromise.resolve(expectedSearchResult)

                        expect(future.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.value).to(beIdenticalTo(expectedSearchResult))
                    }
                }

                context("when the event repo calls the error handler") {
                    it("resolves the promise on the result queue with the error") {
                        let future = subject.fetchEventsWithZipCode("12345", radiusMiles: 42.0)
                        workerQueue.lastReceivedBlock()

                        let expectedError = EventRepositoryError.InvalidJSONError(jsonObject: "wat")
                        eventRepository.lastReturnedPromise.reject(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        switch(future.error!) {
                        case .InvalidJSONError(let jsonObject):
                            expect((jsonObject as! String)).to(equal("wat"))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }
            }
        }
    }
}
