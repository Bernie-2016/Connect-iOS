import CoreLocation

@testable import Connect

class MockLocationManagerProxy: LocationManagerProxy {
    var returnedAuthorizationStatus: CLAuthorizationStatus = .NotDetermined

    var observers = [LocationManagerProxyObserver]()
    func addObserver(observer: LocationManagerProxyObserver) {
        observers.append(observer)
    }

    func authorizationStatus() -> CLAuthorizationStatus {
        return returnedAuthorizationStatus
    }

    var didRequestInUseAuthorization = false
    func requestWhenInUseAuthorization() {
        didRequestInUseAuthorization = true
    }

    func notifyObserversOfChangedAuthorizationStatus(status: CLAuthorizationStatus) {
        for observer in observers {
            observer.locationManagerProxy(self, didChangeAuthorizationStatus: status)
        }
    }

    var didStartUpdatingLocations = false
    func startUpdatingLocations() {
        didStartUpdatingLocations = true
    }

    func notifyObserversOfNewLocations(locations: [CLLocation]) {
        for observer in observers {
            observer.locationManagerProxy(self, didUpdateLocations: locations)
        }
    }

    func notifyObserversOfError(error: NSError) {
        for observer in observers {
            observer.locationManagerProxy(self, didFailWithError: error)
        }
    }
}
