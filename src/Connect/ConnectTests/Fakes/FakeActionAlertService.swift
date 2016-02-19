@testable import Connect

class FakeActionAlertService: ActionAlertService {
    var fetchActionAlertsCalled = false
    var lastReturnedActionAlertsPromise: ActionAlertsPromise!

    func fetchActionAlerts() -> ActionAlertsFuture {
        fetchActionAlertsCalled = true
        lastReturnedActionAlertsPromise = ActionAlertsPromise()
        return lastReturnedActionAlertsPromise.future
    }

    var fetchActionAlertCalled = false
    var lastReturnedActionAlertPromise: ActionAlertPromise!
    var lastReceivedIdentifier: String!
    func fetchActionAlert(identifier: String) -> ActionAlertFuture {
        lastReceivedIdentifier = identifier
        fetchActionAlertCalled = true
        lastReturnedActionAlertPromise = ActionAlertPromise()
        return lastReturnedActionAlertPromise.future
    }
}
