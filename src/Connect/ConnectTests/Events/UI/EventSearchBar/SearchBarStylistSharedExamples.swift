import Quick
import Nimble

@testable import Connect

class SearchBarStylistSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a controller that applies the search bar stylist") { (sharedExampleContext: SharedExampleContext) in
            var searchBarStylist: MockSearchBarStylist!
            var containerView: UIView!
            var searchBar: UISearchBar!

            beforeEach {
                searchBarStylist = sharedExampleContext()["searchBarStylist"] as! MockSearchBarStylist
                containerView = sharedExampleContext()["containerView"] as! UIView
                searchBar = sharedExampleContext()["searchBar"] as! UISearchBar
            }

            it("applies the stylist to the view") {
                expect(searchBarStylist.styledBackground) === containerView
            }

            it("applies the stylist to the search bar") {
                expect(searchBarStylist.styledSearchBar) === searchBar
            }
        }
    }
}
