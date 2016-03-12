import Quick
import Nimble

@testable import Connect

class MockLocationPermissionUseCase: LocationPermissionUseCase {

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
        for handler in permissionGrantedHandlers {
            handler()
        }
    }

    func denyPermission() {
        for handler in permissionErrorHandlers {
            handler()
        }
    }
}
