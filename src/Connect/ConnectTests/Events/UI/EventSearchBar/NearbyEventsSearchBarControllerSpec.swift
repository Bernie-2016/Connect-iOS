import Quick
import Nimble

@testable import Connect

class NearbyEventsSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("NearbyEventsSearchBarController") {
            var subject: NearbyEventsSearchBarController!
            var searchBarStylist: MockSearchBarStylist!
            var delegate: MockNearbyEventsSearchBarControllerDelegate!
            var radiusDataSource: MockRadiusDataSource!
            var resultQueue: FakeOperationQueue!
            var analyticsService: FakeAnalyticsService!
            let theme = SearchBarFakeTheme()

            var window: UIWindow!

            beforeEach {
                searchBarStylist = MockSearchBarStylist()
                radiusDataSource = MockRadiusDataSource()
                resultQueue = FakeOperationQueue()
                analyticsService = FakeAnalyticsService()

                subject = NearbyEventsSearchBarController(
                    searchBarStylist: searchBarStylist,
                    radiusDataSource: radiusDataSource,
                    resultQueue: resultQueue,
                    analyticsService: analyticsService,
                    theme: theme
                )

                delegate = MockNearbyEventsSearchBarControllerDelegate()
                subject.delegate = delegate

                window = UIWindow()
                window.addSubview(subject.view)
                window.makeKeyAndVisible()
            }

            describe("when the view loads") {
                it("has the search bar as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBar))
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

                it("sets the placeholder text") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.placeholder) == "Current Location"
                }

                it("sets the accessibility label on the search bar") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.accessibilityLabel) == "ZIP Code"
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

            describe("as a radius data source observer") {
                describe("when the selected radius is updated") {
                    it("updates the filter button text") {
                        radiusDataSource.simulateConfirmingSelection(123)
                        resultQueue.lastReceivedBlock()

                        expect(subject.filterButton.titleForState(.Normal)) == "123 miles"
                    }
                }
            }

            describe("when tapping on the search bar") {
                it("prevents the search bar from becoming first responder") {
                    subject.searchBar.becomeFirstResponder()

                    expect(subject.searchBar.isFirstResponder()) == false
                }

                it("notifies its delegate that editing has begun") {
                    subject.searchBar.becomeFirstResponder()

                    expect(delegate.didBeginEditingWithController) === subject
                }

                it("should log an event via the analytics service") {
                    subject.searchBar.becomeFirstResponder()

                    expect(analyticsService.lastCustomEventName).to(equal("Tapped on address search bar on Nearby Events"))
                    expect(analyticsService.lastCustomEventAttributes).to(beNil())
                }
            }

            describe("when tapping on the filter button") {
                it("notifies its delegate that filtering has begun") {
                    subject.filterButton.tap()

                    expect(delegate.didBeginFilteringWithController) === subject
                }
            }
        }
    }
}

private class MockNearbyEventsSearchBarControllerDelegate: NearbyEventsSearchBarControllerDelegate {
    var didBeginEditingWithController: NearbyEventsSearchBarController?
    func nearbyEventsSearchBarControllerDidBeginEditing(controller: NearbyEventsSearchBarController) {
        didBeginEditingWithController = controller
    }

    var didBeginFilteringWithController: NearbyEventsSearchBarController?
    func nearbyEventsSearchBarControllerDidBeginFiltering(controller: NearbyEventsSearchBarController) {
        didBeginFilteringWithController = controller
    }
}
