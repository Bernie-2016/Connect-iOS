import UIKit
import CoreLocation

class NewEventsController: UIViewController {
    private let interstitialController: UIViewController
    private let resultsController: UIViewController
    private let errorController: UIViewController
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let childControllerBuddy: ChildControllerBuddy
    private let tabBarItemStylist: TabBarItemStylist

    let resultsView = UIView.newAutoLayoutView()

    init(
        interstitialController: UIViewController,
        resultsController: UIViewController,
        errorController: UIViewController,
        nearbyEventsUseCase: NearbyEventsUseCase,
        childControllerBuddy: ChildControllerBuddy,
        tabBarItemStylist: TabBarItemStylist) {
            self.interstitialController = interstitialController
            self.resultsController = resultsController
            self.errorController = errorController
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.childControllerBuddy = childControllerBuddy
            self.tabBarItemStylist = tabBarItemStylist

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
        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(10.0) // let's kill this magic number

        setupConstraints()
    }

    private func setupConstraints() {
        resultsView.autoPinEdgesToSuperviewEdges()
    }
}

extension NewEventsController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {
        childControllerBuddy.swap(interstitialController, new: resultsController, parent: self) {}
    }
    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        childControllerBuddy.swap(interstitialController, new: resultsController, parent: self) {}
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {
        childControllerBuddy.swap(interstitialController, new: errorController, parent: self) {}
    }
}
