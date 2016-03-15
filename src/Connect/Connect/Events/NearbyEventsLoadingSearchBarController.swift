import UIKit

class NearbyEventsLoadingSearchBarController: UIViewController {
    private let searchBarStylist: SearchBarStylist

    let searchBar = UISearchBar.newAutoLayoutView()

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

        setupConstraints()
        searchBarStylist.applyThemeToBackground(view)
        searchBarStylist.applyThemeToSearchBar(searchBar)

        searchBar.userInteractionEnabled = false
        searchBar.placeholder = NSLocalizedString("EventsSearchBar_loadingNearbyEvents",  comment: "")

        view.alpha = 0.75
    }

    private func setupConstraints() {
        let verticalShift: CGFloat = 8
        let horizontalPadding: CGFloat = 15
        let searchBarHeight: CGFloat = 34

        searchBar.autoCenterInSuperview()
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
