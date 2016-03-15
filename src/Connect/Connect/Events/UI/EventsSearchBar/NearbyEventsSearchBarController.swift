import UIKit

protocol NearbyEventsSearchBarControllerDelegate {
    func nearbyEventsSearchBarControllerDidBeginEditing(controller: NearbyEventsSearchBarController)
    func nearbyEventsSearchBarControllerDidBeginFiltering(controller: NearbyEventsSearchBarController)
}

class NearbyEventsSearchBarController: UIViewController {
    private let searchBarStylist: SearchBarStylist

    let searchBar = UISearchBar.newAutoLayoutView()

    var delegate: NearbyEventsSearchBarControllerDelegate?

    init(searchBarStylist: SearchBarStylist) {
        self.searchBarStylist = searchBarStylist

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.clipsToBounds = true
        view.addSubview(searchBar)

        searchBarStylist.applyThemeToSearchBar(searchBar)
        searchBarStylist.applyThemeToBackground(view)

        searchBar.placeholder = NSLocalizedString("EventsSearchBar_foundNearbyResults", comment: "")
        searchBar.accessibilityLabel = NSLocalizedString("EventsSearchBar_searchBarAccessibilityLabel",  comment: "")
        searchBar.delegate = self

        setupConstraints()
    }

    private func setupConstraints() {
        let searchBarBottomPadding: CGFloat = 10
        let verticalShift: CGFloat = 8
        let horizontalPadding: CGFloat = 15
        let searchBarHeight: CGFloat = 34

        searchBar.autoPinEdgeToSuperviewEdge(.Top, withInset: searchBarBottomPadding)
        searchBar.autoPinEdgeToSuperviewEdge(.Left, withInset: -horizontalPadding)
        searchBar.autoPinEdgeToSuperviewEdge(.Right, withInset: -horizontalPadding)

        if let searchBarContainer = searchBar.subviews.first {
            searchBarContainer.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: verticalShift)
            searchBarContainer.autoPinEdgeToSuperviewEdge(.Left, withInset: horizontalPadding)
            searchBarContainer.autoPinEdgeToSuperviewEdge(.Right, withInset: horizontalPadding)
            searchBarContainer.autoSetDimension(.Height, toSize: searchBarHeight)
        }

        if let textField = searchBar.valueForKey("searchField") as? UITextField {
            textField.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: verticalShift)
            textField.autoPinEdgeToSuperviewEdge(.Left, withInset: horizontalPadding)
            textField.autoPinEdgeToSuperviewEdge(.Right, withInset: horizontalPadding)
            textField.autoSetDimension(.Height, toSize: searchBarHeight)
        }

        if let background = searchBar.valueForKey("background") as? UIView {
            background.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: verticalShift)
            background.autoPinEdgeToSuperviewEdge(.Left)
            background.autoPinEdgeToSuperviewEdge(.Right)
            background.autoSetDimension(.Height, toSize: searchBarHeight)
        }
    }
}

extension NearbyEventsSearchBarController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        delegate?.nearbyEventsSearchBarControllerDidBeginEditing(self)

        return false
    }
}
