import UIKit

class ResponderButton: UIButton {
    var buttonInputView: UIView!
    var buttonInputAccessoryView: UIView!

    override var inputView: UIView { get {
        if buttonInputView != nil {
            return buttonInputView
        }
        else {
            return super.inputView!
        }

        }}

    override var inputAccessoryView: UIView {
        get {
            if buttonInputAccessoryView != nil {
                return buttonInputAccessoryView
            }
            else {
                return super.inputAccessoryView!
            }

        }
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
}
