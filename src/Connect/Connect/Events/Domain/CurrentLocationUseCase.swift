import Foundation
import CoreLocation

protocol CurrentLocationUseCase {
    func addObserver(observer: CurrentLocationUseCaseObserver)
    func fetchCurrentLocation()
}

protocol CurrentLocationUseCaseObserver :class {
    func currentLocationUseCase(useCase: CurrentLocationUseCase, didFetchCurrentLocation  location: CLLocation)
    func currentLocationUseCaseFailedToFetchLocation()
}
