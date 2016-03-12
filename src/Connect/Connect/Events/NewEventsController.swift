import UIKit
import CoreLocation

class NewEventsController: UIViewController {
    private let interstitialController: UIViewController
    private let resultsController: UIViewController
    private let errorController: UIViewController
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let fetchEventsUseCase: FetchEventsUseCase
    private let childControllerBuddy: ChildControllerBuddy

    let resultsView = UIView.newAutoLayoutView()

    init(
        interstitialController: UIViewController,
        resultsController: UIViewController,
        errorController: UIViewController,
        nearbyEventsUseCase: NearbyEventsUseCase,
        fetchEventsUseCase: FetchEventsUseCase,
        childControllerBuddy: ChildControllerBuddy) {
            self.interstitialController = interstitialController
            self.resultsController = resultsController
            self.errorController = errorController
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.fetchEventsUseCase = fetchEventsUseCase
            self.childControllerBuddy = childControllerBuddy

            super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(resultsView)

        nearbyEventsUseCase.addObserver(self)

        childControllerBuddy.add(interstitialController, to: self, containIn: resultsView)
        nearbyEventsUseCase.fetchNearbyEvents()
    }
}

extension NewEventsController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEvents: [Event]) {
        childControllerBuddy.swap(interstitialController, new: resultsController, parent: self) {}
    }
    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        childControllerBuddy.swap(interstitialController, new: resultsController, parent: self) {}
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {
        childControllerBuddy.swap(interstitialController, new: errorController, parent: self) {}
    }
}
