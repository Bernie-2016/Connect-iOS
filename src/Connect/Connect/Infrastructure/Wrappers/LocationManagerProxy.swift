import CoreLocation

protocol LocationManagerProxy {
    func addObserver(observer: LocationManagerProxyObserver)
    func authorizationStatus() -> CLAuthorizationStatus
    func requestAlwaysAuthorization()
    func startUpdatingLocations()
}

protocol LocationManagerProxyObserver :class {
    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didUpdateLocations locations: [CLLocation])

    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didFailWithError error: NSError)
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

    func startUpdatingLocations() {
        locationManager.startUpdatingLocation()
    }
}

extension StockLocationManagerProxy: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        for observer in observers {
            observer.locationManagerProxy(self, didChangeAuthorizationStatus: status)
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for observer in observers {
            observer.locationManagerProxy(self, didUpdateLocations: locations)
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        for observer in observers {
            observer.locationManagerProxy(self, didFailWithError: error)
        }
    }
}
