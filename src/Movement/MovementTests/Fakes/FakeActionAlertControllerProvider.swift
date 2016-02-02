@testable import Movement

class FakeActionAlertControllerProvider: ActionAlertControllerProvider {
    var lastActionAlertReceived: ActionAlert!
    let returnedController = TestUtils.actionAlertController()

    func provideInstanceWithActionAlert(actionAlert: ActionAlert) -> ActionAlertController {
        lastActionAlertReceived = actionAlert
        return returnedController
    }
}
