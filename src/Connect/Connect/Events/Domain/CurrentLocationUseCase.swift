import Foundation
import CoreLocation

enum CurrentLocationUseCaseError: ErrorType {
    case PermissionsError
    case CoreLocationError(NSError)
}

extension CurrentLocationUseCaseError: Equatable {
}

func == (lhs: CurrentLocationUseCaseError, rhs: CurrentLocationUseCaseError) -> Bool {
    switch (lhs, rhs) {
    case (.PermissionsError, .PermissionsError):
        return true
    case (.CoreLocationError(let lhsError), .CoreLocationError(let rhsError)):
        return lhsError == rhsError
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

protocol CurrentLocationUseCase {
    func addObserver(observer: CurrentLocationUseCaseObserver)
    func fetchCurrentLocation()
    func fetchCurrentLocation(successHandler: (CLLocation) -> (), errorHandler: (CurrentLocationUseCaseError) -> ())
}

protocol CurrentLocationUseCaseObserver :class {
    func currentLocationUseCase(useCase: CurrentLocationUseCase, didFetchCurrentLocation  location: CLLocation)
    func currentLocationUseCaseFailedToFetchLocation(useCase: CurrentLocationUseCase)
}

class StockCurrentLocationUseCase: CurrentLocationUseCase {
    let locationManagerProxy: LocationManagerProxy
    let locationPermissionUseCase: LocationPermissionUseCase

    var successHandlers: [(CLLocation) -> ()] = []
    var errorHandlers: [(CurrentLocationUseCaseError) -> ()] = []

    var lastReceivedLocation: CLLocation?
    var lastReceivedError: NSError?

    init(locationManagerProxy: LocationManagerProxy, locationPermissionUseCase: LocationPermissionUseCase) {
        self.locationManagerProxy = locationManagerProxy
        self.locationPermissionUseCase = locationPermissionUseCase

        locationManagerProxy.addObserver(self)
    }


    func addObserver(observer: CurrentLocationUseCaseObserver) {

    }

    func fetchCurrentLocation() {

    }

    func fetchCurrentLocation(successHandler: (CLLocation) -> (), errorHandler: (CurrentLocationUseCaseError) -> ()) {
        if let lastReceivedLocation = lastReceivedLocation {
            successHandler(lastReceivedLocation)
            return
        }
        if let lastReceivedError = lastReceivedError {
            errorHandler(.CoreLocationError(lastReceivedError))
            return
        }

        locationPermissionUseCase.askPermission({ () -> Void in
            self.successHandlers.append(successHandler)
            self.errorHandlers.append(errorHandler)
            self.locationManagerProxy.startUpdatingLocations()
            }) { errorHandler(.PermissionsError) }
    }
}

extension StockCurrentLocationUseCase: LocationManagerProxyObserver {
    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didFailWithError error: NSError) {
        for handler in errorHandlers {
            handler(.CoreLocationError(error))
        }
        errorHandlers.removeAll()

        lastReceivedLocation = nil
        lastReceivedError = error
    }

    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

    }

    func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didUpdateLocations locations: [CLLocation]) {
        for handler in successHandlers {
            handler(locations.last!)
        }
        successHandlers.removeAll()

        lastReceivedLocation = locations.last
        lastReceivedError = nil
    }
}
