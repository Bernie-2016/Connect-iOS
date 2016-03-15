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
        if let textField = searchBar.valueForKey("searchField") as? UITextField {
            textField.textColor = self.theme.eventsZipCodeTextColor()
            textField.font = self.theme.eventsSearchBarFont()
            textField.backgroundColor = self.theme.eventsZipCodeBackgroundColor()
            textField.layer.borderColor = self.theme.eventsZipCodeBorderColor().CGColor
            textField.layer.borderWidth = self.theme.eventsZipCodeBorderWidth()
            textField.layer.cornerRadius = self.theme.eventsZipCodeCornerRadius()
            textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Events_zipCodeTextBoxPlaceholder",  comment: ""),
                attributes:[NSForegroundColorAttributeName: self.theme.eventsZipCodePlaceholderTextColor()])
        }
    }
}
