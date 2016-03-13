import UIKit
import CoreLocation

class NewEventsController: UIViewController {
    private let interstitialController: UIViewController
    private let resultsController: UIViewController
    private let errorController: UIViewController
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let childControllerBuddy: ChildControllerBuddy
    private let tabBarItemStylist: TabBarItemStylist
    private let workerQueue: NSOperationQueue
    private let resultQueue: NSOperationQueue


    let resultsView = UIView.newAutoLayoutView()

    init(
        interstitialController: UIViewController,
        resultsController: UIViewController,
        errorController: UIViewController,
        nearbyEventsUseCase: NearbyEventsUseCase,
        childControllerBuddy: ChildControllerBuddy,
        tabBarItemStylist: TabBarItemStylist,
        workerQueue: NSOperationQueue,
        resultQueue: NSOperationQueue) {
            self.interstitialController = interstitialController
            self.resultsController = resultsController
            self.errorController = errorController
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.childControllerBuddy = childControllerBuddy
            self.tabBarItemStylist = tabBarItemStylist
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

        view.addSubview(resultsView)

        navigationItem.title = NSLocalizedString("Events_navigationTitle", comment: "")
        let backBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Events_backButtonTitle", comment: ""),
            style: .Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        nearbyEventsUseCase.addObserver(self)

        childControllerBuddy.add(interstitialController, to: self, containIn: resultsView)

        workerQueue.addOperationWithBlock {
            self.nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(10.0) // let's kill this magic number
        }

        setupConstraints()
    }

    private func setupConstraints() {
        resultsView.autoPinEdgesToSuperviewEdges()
    }
}

extension NewEventsController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {
        resultQueue.addOperationWithBlock {
            self.childControllerBuddy.swap(self.interstitialController, new: self.resultsController, parent: self) {}
        }
    }
    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        resultQueue.addOperationWithBlock {
            self.childControllerBuddy.swap(self.interstitialController, new: self.resultsController, parent: self) {}
        }
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {
        resultQueue.addOperationWithBlock {
            self.childControllerBuddy.swap(self.interstitialController, new: self.errorController, parent: self) {}
        }
    }
}
