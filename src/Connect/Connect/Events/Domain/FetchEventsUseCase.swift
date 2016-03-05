import CoreLocation

protocol FetchEventsUseCase {
    func fetchEventsAroundLocation(location: CLLocation, radiusMiles: Float)
}
