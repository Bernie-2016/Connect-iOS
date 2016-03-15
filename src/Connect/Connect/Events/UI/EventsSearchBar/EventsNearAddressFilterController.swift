import UIKit

class EventsNearAddressFilterController: UIViewController {
    var delegate: EventsNearAddressFilterControllerDelegate?
}

protocol EventsNearAddressFilterControllerDelegate {
    func eventsNearAddressFilterControllerDidCancel(controller: EventsNearAddressFilterController)
}
