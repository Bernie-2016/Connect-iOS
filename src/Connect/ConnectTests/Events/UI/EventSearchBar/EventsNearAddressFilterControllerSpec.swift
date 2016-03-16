import Quick
import Nimble

@testable import Connect

class EventsNearAddressFilterControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsNearAddressFilterController") {
            var subject: EventsNearAddressFilterController!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var radiusDataSource: MockRadiusDataSource!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!
            let theme = SearchBarFakeTheme()

            var delegate: MockEventsNearAddressFilterControllerDelegate!

            var window: UIWindow!

            beforeEach {
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                radiusDataSource = MockRadiusDataSource()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = EventsNearAddressFilterController(
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    radiusDataSource: radiusDataSource,
                    workerQueue: workerQueue,
                    resultQueue: resultQueue,
                    theme: theme
                )

                window = UIWindow()
                window.addSubview(subject.view)
                window.makeKeyAndVisible()

                delegate = MockEventsNearAddressFilterControllerDelegate()
                subject.delegate = delegate
            }

            describe("when the view is loaded") {
                it("adds the search button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchButton))
                }

                it("adds the filter button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.cancelButton))
                }

                it("has the correct text for the search button") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.titleForState(.Normal)) == "Search"
                }

                it("has the correct text for the cancel button") {
                    subject.view.layoutSubviews()

                    expect(subject.cancelButton.titleForState(.Normal)) == "Cancel"
                }

                it("initially disables the search button") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.enabled) == false
                }

                it("applies the theme to the view components") {
                    subject.view.layoutSubviews()

                    expect(subject.view.backgroundColor) == UIColor.greenColor()

                    expect(subject.searchButton.titleColorForState(.Normal)) == UIColor(rgba: "#111111")
                    expect(subject.searchButton.titleColorForState(.Disabled)) == UIColor(rgba: "#abcdef")
                    expect(subject.searchButton.titleLabel!.font) == UIFont.boldSystemFontOfSize(4444)

                    expect(subject.cancelButton.titleColorForState(.Normal)) == UIColor(rgba: "#111111")
                    expect(subject.cancelButton.titleColorForState(.Disabled)) == UIColor(rgba: "#abcdef")
                    expect(subject.cancelButton.titleLabel!.font) == UIFont.boldSystemFontOfSize(4444)
                }

                it("has the picker view as the input view of the search button") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.inputView) === subject.pickerView
                }

                it("wires up the picker view to the radius data source") {
                    subject.view.layoutSubviews()

                    expect(subject.pickerView.delegate) === radiusDataSource
                    expect(subject.pickerView.dataSource) === radiusDataSource
                }
            }

            describe("when the view did appear") {
                beforeEach {
                    subject.viewDidAppear(false)
                }

                it("makes the search button the first responder") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.isFirstResponder()) == true
                }
            }

            describe("as an events near address use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when a search is initiated") {
                    it("enables the search button") {
                        eventsNearAddressUseCase.simulateStartOfFetch()
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchButton.enabled) == true
                    }
                }
            }

            describe("when search is tapped") {
                beforeEach {
                    subject.view.layoutSubviews()
                    eventsNearAddressUseCase.simulateStartOfFetch()
                    resultQueue.lastReceivedBlock()
                }

                it("confirms the selection on the radius data source") {
                    subject.searchButton.tap()

                    expect(radiusDataSource.didConfirmSelection) == true
                }

                it("start a new fetch on the nearby events use case with the radius picker's radius") {
                    radiusDataSource.returnedCurrentMilesValue = 666

                    subject.searchButton.tap()

                    workerQueue.lastReceivedBlock()

                    expect(eventsNearAddressUseCase.lastSearchedAddress) == "simulated address"
                    expect(eventsNearAddressUseCase.lastSearchedRadius) == 666
                }
            }

            describe("when cancel is tapped") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("notifies the delegate") {
                    subject.cancelButton.tap()

                    expect(delegate.didCancelWithController) === subject
                }
            }
        }
    }
}

class MockEventsNearAddressFilterControllerDelegate: EventsNearAddressFilterControllerDelegate {
    var didCancelWithController: EventsNearAddressFilterController?
    func eventsNearAddressFilterControllerDidCancel(controller: EventsNearAddressFilterController) {
        didCancelWithController = controller
    }
}

