import Quick
import Nimble

@testable import Connect

class StockSearchBarStylistSpec: QuickSpec {
    override func spec() {
        describe("StockSearchBarStylist") {
            var subject: SearchBarStylist!
            let theme = EventsSearchBarFakeTheme()
            var searchBarController: FakeSearchBarController!

            beforeEach {
                searchBarController = FakeSearchBarController()

                subject = StockSearchBarStylist(theme: theme)
            }

            describe("styling the background") {
                it("applies the theme correctly") {
                    subject.applyThemeToBackground(searchBarController.view)

                    expect(searchBarController.view.backgroundColor) == UIColor.greenColor()
                }
            }

            describe("styling the search bar") {
                it("applies the theme correctly") {
                    subject.applyThemeToSearchBar(searchBarController.searchBar)

                    var searchBarTextFieldTested = false
                    if let textField = searchBarController.searchBar.valueForKey("searchField") as? UITextField {                               searchBarTextFieldTested = true
                        expect(textField.backgroundColor) == UIColor.brownColor()
                        expect(textField.font) == UIFont.boldSystemFontOfSize(4444)
                        expect(textField.textColor) == UIColor.redColor()
                        expect(textField.layer.cornerRadius) == 100.0
                        expect(textField.layer.borderWidth) == 200.0

                        let borderColor = UIColor(CGColor: textField.layer.borderColor!)
                        expect(borderColor) == UIColor.orangeColor()
                    }
                    expect(searchBarTextFieldTested) == true
                }
            }
        }
    }
}

private class FakeSearchBarController: UIViewController {
    let searchBar = UISearchBar()
}
