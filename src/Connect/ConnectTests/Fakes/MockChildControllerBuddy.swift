@testable import Connect

class MockChildControllerBuddy: ChildControllerBuddy {
    var lastOldSwappedController: UIViewController!
    var lastNewSwappedController: UIViewController!
    var lastParentSwappedController: UIViewController!

    func swap(old: UIViewController, new: UIViewController, parent: UIViewController) -> UIViewController {
        lastOldSwappedController = old
        lastNewSwappedController = new
        lastParentSwappedController = parent

        return new
    }

    struct AddCall {
        let addController: UIViewController
        let parentController: UIViewController
        let containerView: UIView
    }

    var addCalls: [AddCall] = []
    func add(new: UIViewController, to parent: UIViewController, containIn: UIView) -> UIViewController {
        addCalls.append(AddCall(addController: new, parentController: parent, containerView: containIn))

        return new
    }

    func reset() {
        addCalls.removeAll()

        lastOldSwappedController = nil
        lastNewSwappedController = nil
        lastParentSwappedController = nil
    }
}
