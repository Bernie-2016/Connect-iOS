import Foundation
import CoreLocation

protocol LocationPermissionUseCase {
    func askPermission(grantedHandler: () -> Void, errorHandler: () -> Void)
}

class StockLocationPermissionUseCase: NSObject, LocationPermissionUseCase {
    private let locationManagerProxy: LocationManagerProxy

    private var grantedHandlers: [() -> ()] = []
    private var deniedHandlers: [() -> ()] = []

    init(
        locationManagerProxy: LocationManagerProxy) {
            self.locationManagerProxy = locationManagerProxy

            super.init()

            locationManagerProxy.addObserver(self)
    }

    func askPermission(grantedHandler: () -> Void, errorHandler deniedHandler: () -> Void) {
        switch locationManagerProxy.authorizationStatus() {
        case .NotDetermined:
            grantedHandlers.append(grantedHandler)
            deniedHandlers.append(deniedHandler)

            locationManagerProxy.requestAlwaysAuthorization()
        case .AuthorizedAlways:
            grantedHandler()
        default:
            deniedHandler()
        }
    }
}

extension StockLocationPermissionUseCase: LocationManagerProxyObserver {
    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            for handler in grantedHandlers {
                handler()
            }
            grantedHandlers.removeAll()

        } else {
            for handler in deniedHandlers {
                handler()
            }
            deniedHandlers.removeAll()
        }
    }

    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didUpdateLocations locations: [CLLocation]) {

    }

    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didFailWithError error: NSError) {

    }
}
