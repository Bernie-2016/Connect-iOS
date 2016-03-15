import UIKit

class NearbyEventsSearchBarController: UIViewController {
    var delegate: NearbyEventsSearchBarControllerDelegate?
}

protocol NearbyEventsSearchBarControllerDelegate {
    func nearbyEventsSearchBarControllerDidBeginEditing(controller: NearbyEventsSearchBarController)
    func nearbyEventsSearchBarControllerDidBeginFiltering(controller: NearbyEventsSearchBarController)
}
