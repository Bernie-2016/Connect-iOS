import UIKit

class NearbyEventsLoadingSearchBarController: UIViewController {
    private let searchBarStylist: SearchBarStylist
    private let radiusDataSource: RadiusDataSource
    private let theme: Theme

    let searchBar = UISearchBar.newAutoLayoutView()
    let filterLabel = UILabel.newAutoLayoutView()

    init(searchBarStylist: SearchBarStylist, radiusDataSource: RadiusDataSource, theme: Theme) {
        self.searchBarStylist = searchBarStylist
        self.radiusDataSource = radiusDataSource
        self.theme = theme

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.clipsToBounds = true
        view.addSubview(searchBar)
        view.addSubview(filterLabel)

        setupConstraints()
        applyTheme()
        searchBarStylist.applyThemeToBackground(view)
        searchBarStylist.applyThemeToSearchBar(searchBar)

        let currentRadiusMilesInteger = Int(radiusDataSource.currentMilesValue)
        filterLabel.text = NSString.localizedStringWithFormat(NSLocalizedString("EventsSearchBar_loadingFilterLabel %d", comment: ""), currentRadiusMilesInteger) as String

        searchBar.userInteractionEnabled = false
        searchBar.placeholder = NSLocalizedString("EventsSearchBar_loadingNearbyEvents",  comment: "")
    }

    private func setupConstraints() {
        let searchBarTopPadding: CGFloat = 4
        let verticalShift: CGFloat = 8
        let horizontalPadding: CGFloat = 15
        let searchBarHeight: CGFloat = 30
        let filterLabelBottomPadding: CGFloat = 11

        searchBar.autoPinEdgeToSuperviewEdge(.Top, withInset: searchBarTopPadding)
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

        filterLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: filterLabelBottomPadding)
        filterLabel.autoAlignAxis(.Vertical, toSameAxisOfView: searchBar)
    }

    private func applyTheme() {
        filterLabel.textColor = theme.eventsFilterLabelTextColor()
        filterLabel.font = theme.eventsFilterLabelFont()
    }
}
