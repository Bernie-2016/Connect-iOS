import Quick
import Nimble

@testable import Connect

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

            describe("fetching a particular action alert") {
                it("makes a request to the news article repository on the worker queue") {
                    subject.fetchActionAlert("some-identifier")

                    expect(actionAlertRepository.lastFetchedActionAlertIdentifier).to(beNil())

                    workerQueue.lastReceivedBlock()

                    expect(actionAlertRepository.lastFetchedActionAlertIdentifier).to(equal("some-identifier"))
                }

                context("when the repository resolves its promise with an action alert") {
                    it("resolves its promise with the action alert on the result queue") {
                        let expectedActionAlert = TestUtils.actionAlert()

                        let future = subject.fetchActionAlert("some-identifier")
                        workerQueue.lastReceivedBlock()

                        actionAlertRepository.lastActionAlertPromise.resolve(expectedActionAlert)

                        expect(future.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.value).to(equal(expectedActionAlert))
                    }
                }

                context("when the repository rejects its promise with an error") {
                    it("rejects its promise with the error on the result queue") {
                        let expectedError = ActionAlertRepositoryError.NoMatchingActionAlert("wat")

                        let future = subject.fetchActionAlert("some-identifier")
                        workerQueue.lastReceivedBlock()

                        actionAlertRepository.lastActionAlertPromise.reject(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.error!).to(equal(expectedError))
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

    var lastActionAlertPromise: ActionAlertPromise!
    var lastFetchedActionAlertIdentifier: ActionAlertIdentifier!
    private func fetchActionAlert(identifier: ActionAlertIdentifier) -> ActionAlertFuture {
        lastActionAlertPromise = ActionAlertPromise()
        lastFetchedActionAlertIdentifier = identifier
        return lastActionAlertPromise.future
    }
}
