import Foundation

protocol LocationPermissionUseCase {
    func askPermission() -> Void
}

protocol LocationPermissionUseCaseObserver {
    func locationPermissionUseCaseDidGrantPermission(useCase: LocationPermissionUseCase)
    func locationPermissionUseCaseDidRejectPermission(useCase: LocationPermissionUseCase)
}
