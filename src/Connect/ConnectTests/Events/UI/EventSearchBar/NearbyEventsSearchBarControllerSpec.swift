import Quick
import Nimble

@testable import Connect

class NearbyEventsSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("NearbyEventsSearchBarController") {
            var subject: NearbyEventsSearchBarController!
            var searchBarStylist: MockSearchBarStylist!
            var delegate: MockNearbyEventsSearchBarControllerDelegate!

            var window: UIWindow!

            beforeEach {
                searchBarStylist = MockSearchBarStylist()

                subject = NearbyEventsSearchBarController(
                    searchBarStylist: searchBarStylist
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

                it("sets the placeholder text") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.placeholder) == "Current Location"
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
                it("prevents the search bar from becoming first responder") {
                    subject.searchBar.becomeFirstResponder()

                    expect(subject.searchBar.isFirstResponder()) == false
                }

                it("notifies its delegate that editing has begun") {
                    subject.searchBar.becomeFirstResponder()

                    expect(delegate.didBeginEditingWithController) === subject
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
