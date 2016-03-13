import Quick
import Nimble

@testable import Connect

class EventSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("EventSearchBarController") {
            var subject: EventSearchBarController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var resultQueue: FakeOperationQueue!

            var window : UIWindow!

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                resultQueue = FakeOperationQueue()

                subject = EventSearchBarController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    resultQueue: resultQueue
                )

                window = UIWindow()
                window.addSubview(subject.view)
                window.makeKeyAndVisible()
            }

            it("adds itself as an observer of the nearby events use case on initialization") {
                expect(nearbyEventsUseCase.observers.first as? EventSearchBarController) === subject
            }

            describe("when the view loads") {
                it("has the search bar as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBar))
                }

                it("has the cancel button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.cancelButton))
                }

                it("has the search button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchButton))
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

                        expect(subject.searchBar.placeholder).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "Current Location"
                    }

                    describe("and then the user edits the location") {
                        beforeEach {
                            let searchResult = EventSearchResult(events: [])
                            subject.nearbyEventsUseCase(nearbyEventsUseCase, didFetchEventSearchResult: searchResult)
                            resultQueue.lastReceivedBlock()
                        }

                        itBehavesLike("the standard search bar editing behavior") {
                            [
                                "subject": subject,
                                "eventsNearAddressUseCase":  eventsNearAddressUseCase
                            ]
                        }
                    }
                }

                context("when the use case found no nearby events") {
                    it("sets the search bar placeholder text to Current Location, on the result queue") {
                        subject.nearbyEventsUseCaseFoundNoNearbyEvents(nearbyEventsUseCase)

                        expect(subject.searchBar.placeholder).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "Current Location"
                    }

                    describe("and then the user edits the location") {
                        beforeEach {
                            subject.nearbyEventsUseCaseFoundNoNearbyEvents(nearbyEventsUseCase)
                            resultQueue.lastReceivedBlock()
                        }

                        itBehavesLike("the standard search bar editing behavior") {
                            [
                                "subject": subject,
                                "eventsNearAddressUseCase":  eventsNearAddressUseCase
                            ]
                        }
                    }
                }
            }
        }
    }
}

class SearchBarSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("the standard search bar editing behavior") { (sharedExampleContext: SharedExampleContext) in
            var subject: EventSearchBarController!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!

            beforeEach {
                subject = sharedExampleContext()["subject"] as! EventSearchBarController
                eventsNearAddressUseCase = sharedExampleContext()["eventsNearAddressUseCase"] as! MockEventsNearAddressUseCase
            }

            it("updates the placeholder text") {
                subject.searchBar.becomeFirstResponder()

                expect(subject.searchBar.placeholder) == "ZIP Code"
            }

            it("allows the search bar to be first responder") {
                subject.searchBar.becomeFirstResponder()

                expect(subject.searchBar.isFirstResponder()) == true
            }

            describe("and then the user cancels") {
                beforeEach {
                    subject.searchBar.becomeFirstResponder()
                }

                it("resigns first responder") {
                    subject.cancelButton.tap()

                    expect(subject.searchBar.isFirstResponder()) == false
                }

                it("resets the placeholder text") {
                    subject.cancelButton.tap()

                    expect(subject.searchBar.placeholder) == "Current Location"
                }
            }

            describe("and then the user enters a zipcode") {
                beforeEach {
                    subject.searchBar.becomeFirstResponder()
                }

                context("that is valid") {
                    describe("and the user taps search") {
                        beforeEach {
                            subject.searchBar.text = "90210"
                        }

                        it("calls the find events near address use case with a default radius") {
                            subject.searchButton.tap()

                            expect(eventsNearAddressUseCase.lastSearchedAddress) == "90210"
                            expect(eventsNearAddressUseCase.lastSearchedRadius) == 10.0
                        }

                        it("resigns first responder") {
                            subject.searchButton.tap()

                            expect(subject.searchBar.isFirstResponder()) == false
                        }

                        it("sets the search bar placeholder text to the entered text") {
                            subject.searchButton.tap()

                            expect(subject.searchBar.placeholder) == "90210"
                        }

                        it("nils out the search bar text") {
                            subject.searchButton.tap()

                            expect(subject.searchBar.text) == ""
                        }
                    }
                }
            }
        }
    }
}


private class MockEventsNearAddressUseCase: EventsNearAddressUseCase {
    var lastSearchedAddress: String?
    var lastSearchedRadius: Float?
    func fetchEventsNearAddress(address: Address, radiusMiles: Float) {
        lastSearchedAddress = address
        lastSearchedRadius = radiusMiles
    }
}
