import UIKit

class EditAddressSearchBarController: UIViewController {
    var delegate: EditAddressSearchBarControllerDelegate?
}

protocol EditAddressSearchBarControllerDelegate {
    func editAddressSearchBarControllerDidCancel(controller: EditAddressSearchBarController)
}
