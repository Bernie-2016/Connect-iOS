import UIKit

class EventSearchBarContainerController: UIViewController {
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let nearbyEventsLoadingSearchBarController: UIViewController
    private let nearbyEventsSearchBarController: NearbyEventsSearchBarController
    private let eventsNearAddressSearchBarController: EventsNearAddressSearchBarController
    private let editAddressSearchBarController: EditAddressSearchBarController
    private let nearbyEventsFilterController: NearbyEventsFilterController
    private let eventsNearAddressFilterController: EventsNearAddressFilterController
    private let childControllerBuddy: ChildControllerBuddy
    private let resultQueue: NSOperationQueue

    private var currentViewController: UIViewController!
    private var previousSearchBarController: UIViewController

    init(
        nearbyEventsUseCase: NearbyEventsUseCase,
        eventsNearAddressUseCase: EventsNearAddressUseCase,
        nearbyEventsLoadingSearchBarController: UIViewController,
        nearbyEventsSearchBarController: NearbyEventsSearchBarController,
        eventsNearAddressSearchBarController: EventsNearAddressSearchBarController,
        editAddressSearchBarController: EditAddressSearchBarController,
        nearbyEventsFilterController: NearbyEventsFilterController,
        eventsNearAddressFilterController: EventsNearAddressFilterController,
        childControllerBuddy: ChildControllerBuddy,
        resultQueue: NSOperationQueue
        ) {
        self.nearbyEventsUseCase = nearbyEventsUseCase
        self.eventsNearAddressUseCase = eventsNearAddressUseCase
        self.nearbyEventsLoadingSearchBarController = nearbyEventsLoadingSearchBarController
        self.nearbyEventsSearchBarController = nearbyEventsSearchBarController
        self.eventsNearAddressSearchBarController = eventsNearAddressSearchBarController
        self.editAddressSearchBarController = editAddressSearchBarController
        self.nearbyEventsFilterController = nearbyEventsFilterController
        self.eventsNearAddressFilterController = eventsNearAddressFilterController
        self.childControllerBuddy = childControllerBuddy
        self.resultQueue = resultQueue

        previousSearchBarController = nearbyEventsSearchBarController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nearbyEventsLoadingSearchBarController.view.layoutSubviews()
        nearbyEventsSearchBarController.view.layoutSubviews()
        eventsNearAddressSearchBarController.view.layoutSubviews()
        editAddressSearchBarController.view.layoutSubviews()
        nearbyEventsFilterController.view.layoutSubviews()
        eventsNearAddressFilterController.view.layoutSubviews()

        currentViewController = self.childControllerBuddy.add(nearbyEventsLoadingSearchBarController, to: self, containIn: self.view)

        nearbyEventsUseCase.addObserver(self)
        eventsNearAddressUseCase.addObserver(self)
        nearbyEventsSearchBarController.delegate = self
        eventsNearAddressSearchBarController.delegate = self
        nearbyEventsFilterController.delegate = self
        eventsNearAddressFilterController.delegate = self
        editAddressSearchBarController.delegate = self
    }

    private func swapIn(newController: UIViewController) {
        resultQueue.addOperationWithBlock {
            self.currentViewController = self.childControllerBuddy.swap(
                self.currentViewController,
                new: newController,
                parent: self)
        }
    }
}

// MARK: NearbyEventsUseCaseObserver
extension EventSearchBarContainerController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents error: NearbyEventsUseCaseError) {
        switch error {
        case .FindingLocationError(let locationError):
            switch locationError {
            case .PermissionsError:
                swapIn(eventsNearAddressSearchBarController)
            default:
                swapIn(nearbyEventsSearchBarController)
            }
        default:
            swapIn(nearbyEventsSearchBarController)
        }
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {
        swapIn(nearbyEventsSearchBarController)
    }

    func nearbyEventsUseCaseDidStartFetchingEvents(useCase: NearbyEventsUseCase) {
        swapIn(nearbyEventsLoadingSearchBarController)
    }

    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        swapIn(nearbyEventsSearchBarController)
    }
}

// MARK: EventsNearAddressUseCaseObserver
extension EventSearchBarContainerController: EventsNearAddressUseCaseObserver {
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents error: EventsNearAddressUseCaseError, address: Address) {
        swapIn(eventsNearAddressSearchBarController)
    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult, address: Address) {
        swapIn(eventsNearAddressSearchBarController)
    }

    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address) {
        swapIn(eventsNearAddressSearchBarController)
    }

    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address) {
        swapIn(eventsNearAddressSearchBarController)
    }
}

// MARK: NearbyEventsSearchBarControllerDelegate
extension EventSearchBarContainerController: NearbyEventsSearchBarControllerDelegate {
    func nearbyEventsSearchBarControllerDidBeginEditing(controller: NearbyEventsSearchBarController) {
        previousSearchBarController = controller
        swapIn(editAddressSearchBarController)
    }

    func nearbyEventsSearchBarControllerDidBeginFiltering(controller: NearbyEventsSearchBarController) {
        swapIn(nearbyEventsFilterController)
    }
}

// MARK: EventsNearAddressSearchBarControllerDelegate
extension EventSearchBarContainerController: EventsNearAddressSearchBarControllerDelegate {
    func eventsNearAddressSearchBarControllerDidBeginEditing(controller: EventsNearAddressSearchBarController) {
        previousSearchBarController = controller
        swapIn(editAddressSearchBarController)
    }

    func eventsNearAddressSearchBarControllerDidBeginFiltering(controller: EventsNearAddressSearchBarController) {
        swapIn(eventsNearAddressFilterController)
    }
}

// MARK: NearbyEventsFilterControllerDelegate
extension EventSearchBarContainerController: NearbyEventsFilterControllerDelegate {
    func nearbyEventsFilterControllerDidCancel(controller: NearbyEventsFilterController) {
        swapIn(nearbyEventsSearchBarController)
    }
}

// MARK: EventsNearAddressFilterControllerDelegate
extension EventSearchBarContainerController: EventsNearAddressFilterControllerDelegate {
    func eventsNearAddressFilterControllerDidCancel(controller: EventsNearAddressFilterController) {
        swapIn(eventsNearAddressSearchBarController)
    }
}

// MARK: EditAddressSearchBarControllerDelegate
extension EventSearchBarContainerController: EditAddressSearchBarControllerDelegate {
    func editAddressSearchBarControllerDidCancel(controller: EditAddressSearchBarController) {
        swapIn(previousSearchBarController)
    }
}
