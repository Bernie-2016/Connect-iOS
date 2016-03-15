import Quick
import Nimble

@testable import Connect

class NearbyEventsLoadingSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("NearbyEventsLoadingSearchBarController") {
            var subject: NearbyEventsLoadingSearchBarController!
            let searchBarStylist = MockSearchBarStylist()

            beforeEach {
                subject = NearbyEventsLoadingSearchBarController(
                    searchBarStylist: searchBarStylist
                )
            }

            describe("when the view loads") {
                it("applies the stylist to the view") {
                    subject.view.layoutSubviews()

                    expect(searchBarStylist.styledBackground) === subject.view
                }

                it("applies the stylist to the search bar") {
                    subject.view.layoutSubviews()

                    expect(searchBarStylist.styledSearchBar) === subject.searchBar
                }

                it("sets the placeholder text") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.placeholder) != "Locating..."
                }

                it("disables interaction with the search bar") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.userInteractionEnabled) == false
                }
            }
        }
    }
}
