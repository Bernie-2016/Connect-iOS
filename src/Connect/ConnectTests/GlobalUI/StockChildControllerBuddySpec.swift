import Quick
import Nimble

@testable import Connect

class StockChildControllerBuddySpec: QuickSpec {
    override func spec() {
        describe("StockChildControllerBuddy") {
            var subject: StockChildControllerBuddy!
            var parent: ParentViewControllerSpy!
            var old: ViewControllerSpy!
            var new: ViewControllerSpy!

            beforeEach {
                subject = StockChildControllerBuddy()
                parent = ParentViewControllerSpy()
                old = ViewControllerSpy()
                new = ViewControllerSpy()
            }

            describe("add(new:to:)") {
                beforeEach {
                    subject.add(new, to: parent, containIn: parent.view)
                }

                it("add the child view controller") {
                    expect(parent.addedChildViewControllers).to(contain(new))
                }

                it("tells the child view controller that it moved to a new parent") {
                    expect(new.didMoveToParentViewController).to(beIdenticalTo(parent))
                }

                it("adds the child controller's view to the parent view to be contained in") {
                    expect(parent.view.subviews).to(contain(new.view))
                }

                it("disables auto resizing mask into constraint translation of the contained view (to allow autolayout") {
                    expect(new.view.translatesAutoresizingMaskIntoConstraints).to(beFalse())
                }

                it("adds appropriate constraints to the contained view (to pin it to all 4 edges)") {
                    expect(parent.view.constraints).to(haveCount(4))
                }

                context("when adding the same controller again") {
                    beforeEach {
                        subject.add(new, to: parent, containIn: parent.view)
                    }

                    it("does not call the containment methods again") {
                        expect(parent.addedChildViewControllers).to(haveCount(1))
                    }

                    it("does not add any constraints again") {
                        expect(parent.view.constraints).to(haveCount(4))
                    }
                }
            }

            describe("swap") {
                beforeEach {
                    parent.addChildViewController(old)
                    parent.view.addSubview(old.view)
                    old.didMoveToParentViewController(parent)
                }

                it("add the new view controller as a child view controller") {
                    subject.swap(old, new: new, parent: parent)

                    expect(parent.childViewControllers).to(contain(new))
                }

                it("tells the old view controller that it will move to a nil parent") {
                    subject.swap(old, new: new, parent: parent)

                    expect(old.willMoveToParentViewController).to(beNil())
                }

                it("transitions from the old view controller to the new one") {
                    subject.swap(old, new: new, parent: parent)

                    expect(parent.transitionedFrom).to(beIdenticalTo(old))
                    expect(parent.transitionedTo).to(beIdenticalTo(new))
                }

                context("when the transition is complete") {
                    beforeEach {
                        subject.swap(old, new: new, parent: parent)
                        parent.transitionCompletion(true)
                    }

                    it("tells the new controller that it did move to the parent") {
                        expect(new.didMoveToParentViewController).to(beIdenticalTo(parent))
                    }

                    it("removes the old controller from the parent's child view controllers") {
                        expect(parent.childViewControllers).toNot(contain(old))
                    }
                }
            }
        }
    }
}

private class ParentViewControllerSpy: UIViewController {
    var transitionedFrom: UIViewController!
    var transitionedTo: UIViewController!
    var transitionCompletion: ((Bool) -> Void)!
    var addedChildViewControllers: [UIViewController] = []

    private override func addChildViewController(viewController: UIViewController) {
        addedChildViewControllers.append(viewController)
        super.addChildViewController(viewController)
    }

    private override func transitionFromViewController(fromViewController: UIViewController, toViewController: UIViewController, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: (() -> Void)?, completion: ((Bool) -> Void)?) {
        transitionedFrom = fromViewController
        transitionedTo = toViewController
        transitionCompletion = completion!

        super.transitionFromViewController(fromViewController, toViewController: toViewController, duration: duration, options: options, animations: animations, completion: completion)
    }
}

private class ViewControllerSpy: UIViewController {
    var willMoveToParentViewController: UIViewController!
    private override func willMoveToParentViewController(parent: UIViewController?) {
        willMoveToParentViewController = parent
        super.willMoveToParentViewController(parent)
    }

    var didMoveToParentViewController: UIViewController!
    private override func didMoveToParentViewController(parent: UIViewController?) {
        didMoveToParentViewController = parent
        super.didMoveToParentViewController(parent)
    }
}
