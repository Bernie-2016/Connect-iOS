import UIKit

protocol SearchBarStylist {
    func applyThemeToBackground(view: UIView)
    func applyThemeToSearchBar(searchBar: UISearchBar)
}

class StockSearchBarStylist: SearchBarStylist {
    let theme: Theme

    init(theme: Theme) {
        self.theme = theme
    }

    func applyThemeToBackground(view: UIView) {
        view.backgroundColor = theme.eventsSearchBarBackgroundColor()
    }

    func applyThemeToSearchBar(searchBar: UISearchBar) {
        searchBar.searchBarStyle = .Minimal

        if let textField = searchBar.valueForKey("searchField") as? UITextField {
            let placeholder = textField.placeholder != nil ? textField.placeholder! : ""

            textField.textColor = self.theme.eventsAddressTextColor()
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: self.theme.eventsAddressTextColor()])
            textField.font = self.theme.eventsSearchBarFont()
            textField.backgroundColor = self.theme.eventsAddressBackgroundColor()
            textField.layer.borderColor = self.theme.eventsAddressBorderColor().CGColor
            textField.layer.borderWidth = self.theme.eventsAddressBorderWidth()
            textField.layer.cornerRadius = self.theme.eventsAddressCornerRadius()
        }
    }
}
