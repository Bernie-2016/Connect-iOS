import Quick
import Nimble

@testable import Connect

class NearbyEventsLoadingSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("NearbyEventsLoadingSearchBarController") {
            var subject: NearbyEventsLoadingSearchBarController!
            var searchBarStylist: MockSearchBarStylist!
            var radiusDataSource: MockRadiusDataSource!
            let theme = SearchBarFakeTheme()

            beforeEach {
                searchBarStylist = MockSearchBarStylist()
                radiusDataSource = MockRadiusDataSource()

                subject = NearbyEventsLoadingSearchBarController(
                    searchBarStylist: searchBarStylist,
                    radiusDataSource: radiusDataSource,
                    theme: theme
                )
            }

            describe("when the view loads") {
                it("has the search bar as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBar))
                }

                it("has the filter label as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.filterLabel))
                }

                it("sets the placeholder text") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.placeholder) == "Locating..."
                }

                it("sets the filter text from the radius data source") {
                    radiusDataSource.returnedCurrentMilesValue = 43.7

                    subject.view.layoutSubviews()

                    expect(subject.filterLabel.text) == "Fetching events within 43 miles"
                }

                it("disables interaction with the search bar") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.userInteractionEnabled) == false
                }

                it("uses the theme to style the filter label")  {
                    subject.view.layoutSubviews()

                    expect(subject.filterLabel.textColor) == UIColor.blueColor()
                    expect(subject.filterLabel.font) == UIFont.systemFontOfSize(111)
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
