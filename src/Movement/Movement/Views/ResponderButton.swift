import UIKit

class ResponderButton: UIButton {
    var buttonInputView: UIView!

    override var inputView: UIView { get {
        if buttonInputView != nil {
            return buttonInputView
        }
        else {
            return super.inputView!
        }

        }}

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
}
