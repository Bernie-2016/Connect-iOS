import UIKit

class NearbyEventsFilterController: UIViewController {
    var delegate: NearbyEventsFilterControllerDelegate?
}

protocol NearbyEventsFilterControllerDelegate {
    func nearbyEventsFilterControllerDidCancel(controller: NearbyEventsFilterController)
}
