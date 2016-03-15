import UIKit

class EventsNearAddressSearchBarController: UIViewController {
    var delegate: EventsNearAddressSearchBarControllerDelegate?
}

protocol EventsNearAddressSearchBarControllerDelegate {
    func eventsNearAddressSearchBarControllerDidBeginEditing(controller: EventsNearAddressSearchBarController)
    func eventsNearAddressSearchBarControllerDidBeginFiltering(controller: EventsNearAddressSearchBarController)
}
