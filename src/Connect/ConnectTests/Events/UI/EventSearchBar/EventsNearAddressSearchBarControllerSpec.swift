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
            var radiusDataSource: MockRadiusDataSource!
            let theme = SearchBarFakeTheme()

            var delegate: MockEventsNearAddressSearchBarControllerDelegate!


            var window: UIWindow!

            beforeEach {
                searchBarStylist = MockSearchBarStylist()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                resultQueue = FakeOperationQueue()
                radiusDataSource = MockRadiusDataSource()

                subject = EventsNearAddressSearchBarController(
                    searchBarStylist: searchBarStylist,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    resultQueue: resultQueue,
                    radiusDataSource: radiusDataSource,
                    theme: theme
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

                it("has the filter components as subviews of the controller") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.filterLabel))
                    expect(subject.view.subviews).to(contain(subject.filterButton))
                    expect(subject.view.subviews).to(contain(subject.filterDownArrow))
                }

                it("shows the correct image for the down arrow") {
                    subject.view.layoutSubviews()

                    expect(subject.filterDownArrow.image) == UIImage(named: "downArrow")
                }

                it("styles the filter label and button with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.filterLabel.textColor) == UIColor.blueColor()
                    expect(subject.filterLabel.font) == UIFont.systemFontOfSize(111)
                    expect(subject.filterButton.titleColorForState(.Normal)) == UIColor.greenColor()
                    expect(subject.filterButton.titleLabel!.font) == UIFont.systemFontOfSize(111)
                }

                it("sets the filter label text correctly") {
                    subject.view.layoutSubviews()

                    expect(subject.filterLabel.text) == "Showing events within"
                }

                it("sets the filter button text using the radius data source") {
                    subject.view.layoutSubviews()

                    expect(subject.filterButton.titleForState(.Normal)) == "42 miles"
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

            describe("when tapping on the filter button") {
                it("notifies its delegate that filtering has begun") {
                    subject.filterButton.tap()

                    expect(delegate.didBeginFilteringWithController) === subject
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


            describe("as a radius data source observer") {
                describe("when the selected radius is updated") {
                    it("updates the filter button text") {
                        radiusDataSource.simulateConfirmingSelection(123)
                        resultQueue.lastReceivedBlock()

                        expect(subject.filterButton.titleForState(.Normal)) == "123 miles"
                    }
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
