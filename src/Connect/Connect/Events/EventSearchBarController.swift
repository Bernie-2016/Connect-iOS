import UIKit

class EventSearchBarController: UIViewController {
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let resultQueue: NSOperationQueue

    let searchBar = UISearchBar.newAutoLayoutView()
    let cancelButton = UIButton.newAutoLayoutView()
    let searchButton = UIButton.newAutoLayoutView()

    private var preEditPlaceholder: String?

    init(
        nearbyEventsUseCase: NearbyEventsUseCase,
        eventsNearAddressUseCase: EventsNearAddressUseCase,
        resultQueue: NSOperationQueue) {
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.eventsNearAddressUseCase = eventsNearAddressUseCase
            self.resultQueue = resultQueue

            super.init(nibName: nil, bundle: nil)

            nearbyEventsUseCase.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.addSubview(searchBar)
        view.addSubview(cancelButton)
        view.addSubview(searchButton)

        searchBar.delegate = self

        cancelButton.addTarget(self, action: "didTapCancelButton", forControlEvents: .TouchUpInside)
        searchButton.addTarget(self, action: "didTapSubmitButton", forControlEvents: .TouchUpInside)

        setupConstraints()
    }

    private func setupConstraints() {
        cancelButton.autoPinEdgeToSuperviewEdge(.Left)
        cancelButton.autoAlignAxis(.Horizontal, toSameAxisOfView: searchBar)

        searchButton.autoPinEdgeToSuperviewEdge(.Right)
        searchButton.autoAlignAxis(.Horizontal, toSameAxisOfView: searchBar)

        searchBar.autoPinEdgeToSuperviewEdge(.Top)
        searchBar.autoPinEdge(.Left, toEdge: .Right, ofView: cancelButton)
        searchBar.autoPinEdge(.Right, toEdge: .Left, ofView: searchButton)
        searchBar.autoPinEdgeToSuperviewEdge(.Bottom)
    }
}

extension EventSearchBarController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {
        setPlaceholderToCurrentLocation()
    }

    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        setPlaceholderToCurrentLocation()
    }

    func nearbyEventsUseCaseDidStartFetchingEvents(useCase: NearbyEventsUseCase) {
        resultQueue.addOperationWithBlock {
            self.searchBar.placeholder = NSLocalizedString("EventsSearchBar_loadingNearbyEvents", comment: "")
        }
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {}

    private func setPlaceholderToCurrentLocation() {
        resultQueue.addOperationWithBlock {
            self.searchBar.placeholder = NSLocalizedString("EventsSearchBar_foundNearbyResults", comment: "")
        }
    }
}

extension EventSearchBarController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        preEditPlaceholder = searchBar.placeholder
        searchBar.placeholder = NSLocalizedString("EventsSearchBar_searchBarPlaceholder", comment: "")
        return true
    }
}

extension EventSearchBarController {
    func didTapCancelButton() {
        searchBar.resignFirstResponder()
        searchBar.placeholder = preEditPlaceholder
    }

    func didTapSubmitButton() {
        searchBar.resignFirstResponder()
        eventsNearAddressUseCase.fetchEventsNearAddress(searchBar.text!, radiusMiles: 10.0)
        searchBar.placeholder = searchBar.text
        searchBar.text = nil
    }
}
