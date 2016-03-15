import UIKit

protocol EventsNearAddressSearchBarControllerDelegate {
    func eventsNearAddressSearchBarControllerDidBeginEditing(controller: EventsNearAddressSearchBarController)
    func eventsNearAddressSearchBarControllerDidBeginFiltering(controller: EventsNearAddressSearchBarController)
}

class EventsNearAddressSearchBarController: UIViewController {
    private let searchBarStylist: SearchBarStylist
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let resultQueue: NSOperationQueue

    let searchBar = UISearchBar.newAutoLayoutView()

    var delegate: EventsNearAddressSearchBarControllerDelegate?

    init(searchBarStylist: SearchBarStylist, eventsNearAddressUseCase: EventsNearAddressUseCase, resultQueue: NSOperationQueue) {
        self.searchBarStylist = searchBarStylist
        self.eventsNearAddressUseCase = eventsNearAddressUseCase
        self.resultQueue = resultQueue

        super.init(nibName: nil, bundle: nil)

        eventsNearAddressUseCase.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.clipsToBounds = true
        view.addSubview(searchBar)

        searchBarStylist.applyThemeToSearchBar(searchBar)
        searchBarStylist.applyThemeToBackground(view)

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

// MARK: UISearchBarDelegate
extension EventsNearAddressSearchBarController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        delegate?.eventsNearAddressSearchBarControllerDidBeginEditing(self)

        return false
    }
}

// MARK: EventsNearAddressUseCaseObserver
extension EventsNearAddressSearchBarController: EventsNearAddressUseCaseObserver {
    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address) {

    }

    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address) {
        resultQueue.addOperationWithBlock {
            self.searchBar.placeholder = address
        }
    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult, address: Address) {

    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents error: EventsNearAddressUseCaseError, address: Address) {

    }
}
