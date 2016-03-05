import UIKit

class NearbyNavigationController: UINavigationController {
    let interstitialController: UIViewController
    let eventsController: UIViewController
    let locationPermissionUseCase: LocationPermissionUseCase

    init(
        interstitialController: UIViewController,
        eventsController: UIViewController,
        locationPermissionUseCase: LocationPermissionUseCase) {
            self.interstitialController = interstitialController
            self.eventsController = eventsController
            self.locationPermissionUseCase = locationPermissionUseCase

            super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        pushViewController(interstitialController, animated: false)

        locationPermissionUseCase.addObserver(self)
        locationPermissionUseCase.askPermission()
    }
}

extension NearbyNavigationController: LocationPermissionUseCaseObserver {
    func locationPermissionUseCaseDidGrantPermission(useCase: LocationPermissionUseCase) {
        setViewControllers([eventsController], animated: true)
    }

    func locationPermissionUseCaseDidDenyPermission(useCase: LocationPermissionUseCase) {
        setViewControllers([eventsController], animated: true)    }
}
