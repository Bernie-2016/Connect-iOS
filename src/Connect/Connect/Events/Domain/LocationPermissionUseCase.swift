import Foundation
import CoreLocation

protocol LocationPermissionUseCase {
    func askPermission() -> Void
    func addObserver(observer: LocationPermissionUseCaseObserver)
}

protocol LocationPermissionUseCaseObserver: class {
    func locationPermissionUseCaseDidGrantPermission(useCase: LocationPermissionUseCase)
    func locationPermissionUseCaseDidDenyPermission(useCase: LocationPermissionUseCase)
}

class StockLocationPermissionUseCase: NSObject, LocationPermissionUseCase {
    private let locationManagerProxy: LocationManagerProxy

    private let _observers = NSHashTable.weakObjectsHashTable()
    private var observers: [LocationPermissionUseCaseObserver] {
        return _observers.allObjects.flatMap { $0 as? LocationPermissionUseCaseObserver }
    }

    init(
        locationManagerProxy: LocationManagerProxy) {
            self.locationManagerProxy = locationManagerProxy

            super.init()

            locationManagerProxy.addObserver(self)
    }

    func addObserver(observer: LocationPermissionUseCaseObserver) {
        _observers.addObject(observer)
    }

    func askPermission() {
        switch locationManagerProxy.authorizationStatus() {
        case .NotDetermined:
            locationManagerProxy.requestAlwaysAuthorization()
        case .AuthorizedAlways:
            for observer in observers {
                observer.locationPermissionUseCaseDidGrantPermission(self)
            }
        default:
            for observer in observers {
                observer.locationPermissionUseCaseDidDenyPermission(self)
            }
        }
    }
}

extension StockLocationPermissionUseCase: LocationManagerProxyObserver {
    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            for observer in observers {
                observer.locationPermissionUseCaseDidGrantPermission(self)
            }
        } else {
            for observer in observers {
                observer.locationPermissionUseCaseDidDenyPermission(self)
            }
        }
    }
}
