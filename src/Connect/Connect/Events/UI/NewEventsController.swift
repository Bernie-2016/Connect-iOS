import UIKit
import CoreLocation

class NewEventsController: UIViewController {
    private let searchBarController: UIViewController
    private let interstitialController: UIViewController
    private let resultsController: UIViewController
    private let errorController: UIViewController
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let childControllerBuddy: ChildControllerBuddy
    private let tabBarItemStylist: TabBarItemStylist
    private let radiusDataSource: RadiusDataSource
    private let workerQueue: NSOperationQueue
    private let resultQueue: NSOperationQueue


    let searchBarView = UIView.newAutoLayoutView()
    let resultsView = UIView.newAutoLayoutView()

    private var currentResultsViewController: UIViewController?

    init(
        searchBarController: UIViewController,
        interstitialController: UIViewController,
        resultsController: UIViewController,
        errorController: UIViewController,
        nearbyEventsUseCase: NearbyEventsUseCase,
        eventsNearAddressUseCase: EventsNearAddressUseCase,
        childControllerBuddy: ChildControllerBuddy,
        tabBarItemStylist: TabBarItemStylist,
        radiusDataSource: RadiusDataSource,
        workerQueue: NSOperationQueue,
        resultQueue: NSOperationQueue) {
            self.searchBarController = searchBarController
            self.interstitialController = interstitialController
            self.resultsController = resultsController
            self.errorController = errorController
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.eventsNearAddressUseCase = eventsNearAddressUseCase
            self.childControllerBuddy = childControllerBuddy
            self.tabBarItemStylist = tabBarItemStylist
            self.radiusDataSource = radiusDataSource
            self.workerQueue = workerQueue
            self.resultQueue = resultQueue

            super.init(nibName: nil, bundle: nil)

            tabBarItemStylist.applyThemeToBarBarItem(tabBarItem,
                image: UIImage(named: "eventsTabBarIconInactive")!,
                selectedImage: UIImage(named: "eventsTabBarIcon")!)
            title = NSLocalizedString("Events_tabBarTitle", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(searchBarView)
        view.addSubview(resultsView)

        navigationItem.title = NSLocalizedString("Events_navigationTitle", comment: "")
        let backBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Events_backButtonTitle", comment: ""),
            style: .Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        nearbyEventsUseCase.addObserver(self)
        eventsNearAddressUseCase.addObserver(self)

        setupConstraints()

        childControllerBuddy.add(searchBarController, to: self, containIn: searchBarView)
        currentResultsViewController = childControllerBuddy.add(interstitialController, to: self, containIn: resultsView)

        workerQueue.addOperationWithBlock {
            self.nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(self.radiusDataSource.currentMilesValue)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    private func setupConstraints() {
        searchBarView.autoPinEdgeToSuperviewEdge(.Top)
        searchBarView.autoPinEdgeToSuperviewEdge(.Left)
        searchBarView.autoPinEdgeToSuperviewEdge(.Right)
        searchBarView.autoSetDimension(.Height, toSize: 64 + 20)

        resultsView.autoPinEdge(.Top, toEdge: .Bottom, ofView: searchBarView)
        resultsView.autoPinEdgeToSuperviewEdge(.Left)
        resultsView.autoPinEdgeToSuperviewEdge(.Right)
        resultsView.autoPinEdgeToSuperviewEdge(.Bottom)
    }

    private func showResults() {
        resultQueue.addOperationWithBlock {
            self.currentResultsViewController = self.childControllerBuddy.swap(self.currentResultsViewController!, new: self.resultsController, parent: self)
        }
    }

    private func showErrors() {
        resultQueue.addOperationWithBlock {
            self.currentResultsViewController = self.childControllerBuddy.swap(self.currentResultsViewController!, new: self.errorController, parent: self)
        }
    }

    private func showInterstitial() {
        resultQueue.addOperationWithBlock {
            self.currentResultsViewController = self.childControllerBuddy.swap(self.currentResultsViewController!, new: self.interstitialController, parent: self)
        }
    }
}

extension NewEventsController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {
        showResults()
    }
    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        showResults()
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {
        showErrors()
    }

    func nearbyEventsUseCaseDidStartFetchingEvents(useCase: NearbyEventsUseCase) {}
}

extension NewEventsController: EventsNearAddressUseCaseObserver {
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents: EventsNearAddressUseCaseError, address: Address) {
        showErrors()
    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult: EventSearchResult, address: Address) {
        showResults()
    }

    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address) {
        showInterstitial()
    }

    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address) {
        showResults()
    }
}
