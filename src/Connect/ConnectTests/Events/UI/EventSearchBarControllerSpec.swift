import Quick
import Nimble

@testable import Connect

class EventSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("EventSearchBarController") {
            var subject: EventSearchBarController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var resultQueue: FakeOperationQueue!

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                resultQueue = FakeOperationQueue()

                subject = EventSearchBarController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    resultQueue: resultQueue
                )
            }

            it("adds itself as an observer of the nearby events use case on initialization") {
                expect(nearbyEventsUseCase.observers.first as? EventSearchBarController) === subject
            }

            describe("when the view loads") {
                it("has the search bar as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBar))
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case has found nearby events") {
                    it("sets the search bar text to Current Location, on the result queue") {
                        let searchResult = EventSearchResult(events: [])
                        subject.nearbyEventsUseCase(nearbyEventsUseCase, didFetchEventSearchResult: searchResult)

                        expect(subject.searchBar.text) != "Current Location"

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.text) == "Current Location"
                    }
                }

                context("when the use case found no nearby events") {
                    it("sets the search bar text to Current Location, on the result queue") {
                        subject.nearbyEventsUseCaseFoundNoNearbyEvents(nearbyEventsUseCase)

                        expect(subject.searchBar.text) != "Current Location"

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.text) == "Current Location"
                    }
                }
            }
        }
    }
}

