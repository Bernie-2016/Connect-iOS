import Quick
import Nimble
import CoreLocation

@testable import Movement

class BackgroundEventServiceSpec: QuickSpec {
    override func spec() {
        describe("BackgroundEventService") {
            var subject: EventService!
            var eventRepository: FakeEventRepository!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!


            beforeEach {
                eventRepository = FakeEventRepository()
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

                        let expectedSearchResult = EventSearchResult(searchCentroid: CLLocation(latitude: 12, longitude: 34), events: [])
                        eventRepository.lastCompletionBlock!(expectedSearchResult)

                        expect(future.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.value).to(beIdenticalTo(expectedSearchResult))
                    }
                }

                context("when the event repo calls the error handler") {
                    it("resolves the promise on the result queue with the error") {
                        let future = subject.fetchEventsWithZipCode("12345", radiusMiles: 42.0)
                        workerQueue.lastReceivedBlock()

                        let expectedError = NSError(domain: "rr", code: 123, userInfo: nil)

                        eventRepository.lastErrorBlock!(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.error).to(beIdenticalTo(expectedError))
                    }
                }
            }
        }
    }
}
