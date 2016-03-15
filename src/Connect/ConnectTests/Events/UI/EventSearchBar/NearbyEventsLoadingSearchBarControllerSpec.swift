import Quick
import Nimble

@testable import Connect

class NearbyEventsLoadingSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("NearbyEventsLoadingSearchBarController") {
            var subject: NearbyEventsLoadingSearchBarController!
            var searchBarStylist: MockSearchBarStylist!

            beforeEach {
                searchBarStylist = MockSearchBarStylist()
                subject = NearbyEventsLoadingSearchBarController(
                    searchBarStylist: searchBarStylist
                )
            }

            describe("when the view loads") {
                it("has the search bar as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBar))
                }

                it("sets the placeholder text") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.placeholder) == "Locating..."
                }

                it("disables interaction with the search bar") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.userInteractionEnabled) == false
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
        }
    }
}
