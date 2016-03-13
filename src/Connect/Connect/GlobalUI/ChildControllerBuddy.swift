import Foundation

typealias ChildControllerBuddySwapCompletionHandler = Void -> Void

protocol ChildControllerBuddy {
    func add(new: UIViewController, to parent: UIViewController, containIn: UIView)
    func swap(old: UIViewController, new: UIViewController, parent: UIViewController)
}

struct StockChildControllerBuddy: ChildControllerBuddy {
    func add(new: UIViewController, to parent: UIViewController, containIn: UIView) {
        if !parent.childViewControllers.contains(new) {
            parent.addChildViewController(new)
            containIn.addSubview(new.view)
            new.didMoveToParentViewController(parent)

            new.view.translatesAutoresizingMaskIntoConstraints = false
            containIn.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view": new.view]))
            containIn.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view": new.view]))
        }
    }

    func swap(old: UIViewController, new: UIViewController, parent: UIViewController) {
        parent.addChildViewController(new)
        old.willMoveToParentViewController(nil)

        parent.transitionFromViewController(old, toViewController: new, duration: 0, options: .TransitionNone, animations: {}, completion: { completed in
            new.didMoveToParentViewController(parent)
            old.removeFromParentViewController()
        })
    }
}
