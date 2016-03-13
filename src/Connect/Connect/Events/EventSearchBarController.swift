import UIKit

class EventSearchBarController: UIViewController {
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let resultQueue: NSOperationQueue

    let searchBar = UISearchBar()

    init(
        nearbyEventsUseCase: NearbyEventsUseCase,
        resultQueue: NSOperationQueue) {
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.resultQueue = resultQueue

            super.init(nibName: nil, bundle: nil)

            nearbyEventsUseCase.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.addSubview(searchBar)

        setupConstraints()
    }

    private func setupConstraints() {
        searchBar.autoPinEdgesToSuperviewEdges()
    }
}

extension EventSearchBarController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {

    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {
        setTextToCurrentLocation()
    }

    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        setTextToCurrentLocation()
    }

    private func setTextToCurrentLocation() {
        resultQueue.addOperationWithBlock {
            self.searchBar.text = NSLocalizedString("EventsSearchBar_currentLocation", comment: "")
        }
    }
}
