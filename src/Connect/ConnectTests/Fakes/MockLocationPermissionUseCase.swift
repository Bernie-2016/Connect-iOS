import Quick
import Nimble

@testable import Connect

class MockLocationPermissionUseCase: LocationPermissionUseCase {
    var observers = [LocationPermissionUseCaseObserver]()
    func addObserver(observer: LocationPermissionUseCaseObserver) {
        observers.append(observer)
    }

    var hasBeenAskedForPermission = false
    func askPermission() {
        hasBeenAskedForPermission = true
    }

    func grantPermission() {
        for observer in observers {
            observer.locationPermissionUseCaseDidGrantPermission(self)
        }
    }

    func denyPermission() {
        for observer in observers {
            observer.locationPermissionUseCaseDidDenyPermission(self)
        }
    }
}
