@testable import Connect

class MockSearchBarStylist: SearchBarStylist {
    var styledBackground: UIView?
    func applyThemeToBackground(view: UIView) {
        styledBackground = view
    }

    var styledSearchBar: UISearchBar?
    func applyThemeToSearchBar(searchBar: UISearchBar) {
        styledSearchBar = searchBar
    }
}
