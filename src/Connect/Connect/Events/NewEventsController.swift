import UIKit
import CoreLocation

class NewEventsController: UIViewController {
    private let interstitialController: UIViewController
    private let instructionsController: UIViewController
    private let errorController: UIViewController
    private let locationPermissionUseCase: LocationPermissionUseCase
    private let currentLocationUseCase: CurrentLocationUseCase
    private let fetchEventsUseCase: FetchEventsUseCase
    private let childControllerBuddy: ChildControllerBuddy

    let resultsView = UIView.newAutoLayoutView()

    init(
        interstitialController: UIViewController,
        instructionsController: UIViewController,
        errorController: UIViewController,
        locationPermissionUseCase: LocationPermissionUseCase,
        currentLocationUseCase: CurrentLocationUseCase,
        fetchEventsUseCase: FetchEventsUseCase,
        childControllerBuddy: ChildControllerBuddy) {
            self.interstitialController = interstitialController
            self.instructionsController = instructionsController
            self.errorController = errorController
            self.locationPermissionUseCase = locationPermissionUseCase
            self.currentLocationUseCase = currentLocationUseCase
            self.fetchEventsUseCase = fetchEventsUseCase
            self.childControllerBuddy = childControllerBuddy

            super.init(nibName: nil, bundle: nil)

            locationPermissionUseCase.addObserver(self)
            currentLocationUseCase.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(resultsView)

        childControllerBuddy.add(interstitialController, to: self, containIn: resultsView)
    }
}

extension NewEventsController: LocationPermissionUseCaseObserver {
    func locationPermissionUseCaseDidDenyPermission(useCase: LocationPermissionUseCase) {
        childControllerBuddy.swap(interstitialController, new: instructionsController, parent: self) {}
    }

    func locationPermissionUseCaseDidGrantPermission(useCase: LocationPermissionUseCase) {
        currentLocationUseCase.fetchCurrentLocation()
    }
}

extension NewEventsController: CurrentLocationUseCaseObserver {
    func currentLocationUseCase(useCase: CurrentLocationUseCase, didFetchCurrentLocation location: CLLocation) {
        fetchEventsUseCase.fetchEventsAroundLocation(location, radiusMiles: 10)
    }

    func currentLocationUseCaseFailedToFetchLocation() {
        childControllerBuddy.swap(interstitialController, new: errorController, parent: self) {}
    }
}
