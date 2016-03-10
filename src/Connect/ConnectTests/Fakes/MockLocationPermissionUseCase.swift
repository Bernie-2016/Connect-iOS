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


    var permissionGrantedHandlers: [() -> Void] = []
    var permissionErrorHandlers: [() -> Void] = []
    func askPermission(grantedHandler: () -> Void, errorHandler: () -> Void) {
        hasBeenAskedForPermission = true
        permissionGrantedHandlers.append(grantedHandler)
        permissionErrorHandlers.append(errorHandler)
    }

    func grantPermission() {
        for observer in observers {
            observer.locationPermissionUseCaseDidGrantPermission(self)
        }

        for handler in permissionGrantedHandlers {
            handler()
        }
    }

    func denyPermission() {
        for observer in observers {
            observer.locationPermissionUseCaseDidDenyPermission(self)
        }

        for handler in permissionErrorHandlers {
            handler()
        }
    }
}
