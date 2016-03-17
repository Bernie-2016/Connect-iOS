import Quick
import Nimble

@testable import Connect

class NearbyEventsFilterControllerSpec: QuickSpec {
    override func spec() {
        describe("NearbyEventsFilterController") {
            var subject: NearbyEventsFilterController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var radiusDataSource: MockRadiusDataSource!
            var workerQueue: FakeOperationQueue!
            var analyticsService: FakeAnalyticsService!
            let theme = SearchBarFakeTheme()

            var delegate: MockNearbyEventsFilterControllerDelegate!

            var window: UIWindow!

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                radiusDataSource = MockRadiusDataSource()
                workerQueue = FakeOperationQueue()
                analyticsService = FakeAnalyticsService()

                subject = NearbyEventsFilterController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    radiusDataSource: radiusDataSource,
                    workerQueue: workerQueue,
                    analyticsService: analyticsService,
                    theme: theme
                )

                window = UIWindow()
                window.addSubview(subject.view)
                window.makeKeyAndVisible()

                delegate = MockNearbyEventsFilterControllerDelegate()
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

            describe("when search is tapped") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("confirms the selection on the radius data source") {
                    subject.searchButton.tap()

                    expect(radiusDataSource.didConfirmSelection) == true
                }

                it("start a new fetch on the nearby events use case with the radius picker's radius") {
                    radiusDataSource.returnedCurrentMilesValue = 666

                    subject.searchButton.tap()

                    workerQueue.lastReceivedBlock()

                    expect(nearbyEventsUseCase.didFetchNearbyEventsWithinRadius) == 666
                }

                it("should log an event via the analytics service") {
                    radiusDataSource.returnedCurrentMilesValue = 42

                    subject.searchButton.tap()
                    workerQueue.lastReceivedBlock()

                    expect(analyticsService.lastSearchQuery).to(equal("NEARBY|42.0"))
                    expect(analyticsService.lastSearchContext).to(equal(AnalyticsSearchContext.Events))
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

                it("should log an event via the analytics service") {
                    subject.cancelButton.tap()

                    expect(analyticsService.lastCustomEventName).to(equal("Tapped cancel on Nearby Events Filter"))
                    expect(analyticsService.lastCustomEventAttributes).to(beNil())
                }

            }
        }
    }
}

private class MockNearbyEventsFilterControllerDelegate: NearbyEventsFilterControllerDelegate {
    var didCancelWithController: NearbyEventsFilterController?

    private func nearbyEventsFilterControllerDidCancel(controller: NearbyEventsFilterController) {
        didCancelWithController = controller
    }
}
