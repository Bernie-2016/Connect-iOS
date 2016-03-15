import Quick
import Nimble

@testable import Connect

class EventsNearAddressSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsNearAddressSearchBarController") {
            var subject: EventsNearAddressSearchBarController!
            var searchBarStylist: MockSearchBarStylist!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var resultQueue: FakeOperationQueue!

            var delegate: MockEventsNearAddressSearchBarControllerDelegate!


            var window: UIWindow!

            beforeEach {
                searchBarStylist = MockSearchBarStylist()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                resultQueue = FakeOperationQueue()

                subject = EventsNearAddressSearchBarController(
                    searchBarStylist: searchBarStylist,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    resultQueue: resultQueue
                )

                delegate = MockEventsNearAddressSearchBarControllerDelegate()
                subject.delegate = delegate

                window = UIWindow()
                window.addSubview(subject.view)
                window.makeKeyAndVisible()
            }

            it("adds itself as an observer of the use case upon initialization") {
                expect(eventsNearAddressUseCase.observers.first as? EventsNearAddressSearchBarController) === subject
            }

            describe("when the view loads") {
                it("has the search bar as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBar))
                }

                it("sets the accessibility label on the search bar") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.accessibilityLabel) == "ZIP Code"
                }

                describe("using the search bar stylist") {
                    beforeEach {
                        subject.view.layoutSubviews()
                    }

                    itBehavesLike("a controller that applies the search bar stylist") { [
                        "searchBar": subject.searchBar,
                        "containerView": subject.view,
                        "searchBarStylist": searchBarStylist
                        ] }
                }
            }

            describe("when tapping on the search bar") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("prevents the search bar from becoming first responder") {
                    subject.searchBar.becomeFirstResponder()

                    expect(subject.searchBar.isFirstResponder()) == false
                }

                it("notifies its delegate that editing has begun") {
                    subject.searchBar.becomeFirstResponder()

                    expect(delegate.didBeginEditingWithController) === subject
                }
            }

            describe("as an events near address use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when the use case begins a search") {
                    it("sets the search bar placeholder appropriately") {
                        eventsNearAddressUseCase.simulateStartOfFetch()
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "simulated address"
                    }
                }
            }
        }
    }
}

private class MockEventsNearAddressSearchBarControllerDelegate: EventsNearAddressSearchBarControllerDelegate {
    var didBeginEditingWithController: EventsNearAddressSearchBarController?
    func eventsNearAddressSearchBarControllerDidBeginEditing(controller: EventsNearAddressSearchBarController) {
        didBeginEditingWithController = controller
    }

    var didBeginFilteringWithController: EventsNearAddressSearchBarController?
    func eventsNearAddressSearchBarControllerDidBeginFiltering(controller: EventsNearAddressSearchBarController) {
        didBeginFilteringWithController = controller
    }
}
