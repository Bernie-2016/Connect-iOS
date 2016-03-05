import CoreLocation

protocol LocationManagerProxy {
    func authorizationStatus() -> CLAuthorizationStatus
    func requestAlwaysAuthorization()
    func addObserver(observer: LocationManagerProxyObserver)
}

protocol LocationManagerProxyObserver :class {
    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didChangeAuthorizationStatus status: CLAuthorizationStatus)
}

class StockLocationManagerProxy: NSObject, LocationManagerProxy {
    private let locationManager: CLLocationManager

    private let _observers = NSHashTable.weakObjectsHashTable()
    private var observers: [LocationManagerProxyObserver] {
        return _observers.allObjects.flatMap { $0 as? LocationManagerProxyObserver }
    }

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager

        super.init()

        self.locationManager.delegate = self
    }

    func addObserver(observer: LocationManagerProxyObserver) {
        _observers.addObject(observer)
    }

    func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
}

extension StockLocationManagerProxy: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        for observer in observers {
            observer.locationManagerProxy(self, didChangeAuthorizationStatus: status)
        }
    }
}
