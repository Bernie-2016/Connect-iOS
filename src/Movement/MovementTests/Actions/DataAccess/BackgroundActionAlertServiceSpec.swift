import Quick
import Nimble

@testable import Movement

class BackgroundActionAlertServiceSpec: QuickSpec {
    override func spec() {
        describe("BackgroundActionAlertService") {
            var subject: ActionAlertService!
            var actionAlertRepository: FakeActionAlertRepository!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!


            beforeEach {
                actionAlertRepository = FakeActionAlertRepository()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = BackgroundActionAlertService(actionAlertRepository: actionAlertRepository, workerQueue: workerQueue, resultQueue: resultQueue)
            }

            describe("fetching action alerts") {
                it("makes a request to the action alert repository on the worker queue") {
                    subject.fetchActionAlerts()

                    expect(actionAlertRepository.fetchActionAlertsCalled).to(beFalse())

                    workerQueue.lastReceivedBlock()

                    expect(actionAlertRepository.fetchActionAlertsCalled).to(beTrue())
                }

                context("when the action alerts repo calls the completion handler") {
                    it("resolves the promise on the result queue with the action alerts") {
                        let future = subject.fetchActionAlerts()
                        workerQueue.lastReceivedBlock()

                        let expectedActionAlert = TestUtils.actionAlert()
                        actionAlertRepository.lastReturnedPromise.resolve([expectedActionAlert])

                        expect(future.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        let result = future.value!
                        expect(result.count).to(equal(1))
                        let actionAlert = result.first

                        expect(actionAlert).to(equal(expectedActionAlert))
                    }
                }

                context("when the action alert repo calls the error handler") {
                    it("resolves the promise on the result queue with the error") {
                        let badObj = "wat"
                        let expectedError = ActionAlertRepositoryError.InvalidJSON(jsonObject: badObj)

                        let future = subject.fetchActionAlerts()
                        workerQueue.lastReceivedBlock()

                        actionAlertRepository.lastReturnedPromise.reject(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.error!).to(equal(ActionAlertRepositoryError.InvalidJSON(jsonObject: badObj)))
                    }
                }
            }
        }
    }
}

private class FakeActionAlertRepository: ActionAlertRepository {
    var lastReturnedPromise: ActionAlertsPromise!
    var fetchActionAlertsCalled = false

    func fetchActionAlerts() -> ActionAlertsFuture {
        lastReturnedPromise = ActionAlertsPromise()
        fetchActionAlertsCalled = true
        return lastReturnedPromise.future
    }
}
