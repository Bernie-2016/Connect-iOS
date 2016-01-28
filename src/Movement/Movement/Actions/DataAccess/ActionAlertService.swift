import Foundation

enum ActionAlertServiceError: ErrorType {
    case BadDad
}

protocol ActionAlertService {
    func fetchActionAlerts() -> ActionAlertsFuture
}

class BackgroundActionAlertService: ActionAlertService {
    let actionAlertRepository: ActionAlertRepository
    let workerQueue: NSOperationQueue
    let resultQueue: NSOperationQueue

    init(actionAlertRepository: ActionAlertRepository, workerQueue: NSOperationQueue, resultQueue: NSOperationQueue) {
        self.actionAlertRepository = actionAlertRepository
        self.workerQueue = workerQueue
        self.resultQueue = resultQueue
    }

    func fetchActionAlerts() -> ActionAlertsFuture {
        let promise = ActionAlertsPromise()

        workerQueue.addOperationWithBlock {
            self.actionAlertRepository.fetchActionAlerts().then { actionAlerts in
                self.resultQueue.addOperationWithBlock({
                    promise.resolve(actionAlerts)
                })
                }.error { error in
                    self.resultQueue.addOperationWithBlock({
                        promise.reject(error)
                    })
            }
        }


        return promise.future
    }
}
