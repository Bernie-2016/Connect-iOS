import Quick
import Nimble

@testable import Connect

class StockNewVersionNotifierSpec: QuickSpec {
    override func spec() {
        describe("StockNewVersionNotifier") {
            var subject: NewVersionNotifier!
            var appVersionCompatibilityUseCase: MockAppVersionCompatibilityUseCase!
            var urlOpener: FakeURLOpener!
            var workQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!

            var controller: UIViewController!


            beforeEach {
                appVersionCompatibilityUseCase = MockAppVersionCompatibilityUseCase()
                urlOpener = FakeURLOpener()
                workQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = StockNewVersionNotifier(
                    appVersionCompatibilityUseCase: appVersionCompatibilityUseCase,
                    urlOpener: urlOpener,
                    workQueue: workQueue,
                    resultQueue: resultQueue
                )

                controller = UIViewController()
            }

            describe("checking if the app's version is supported") {
                it("asks the app version compatibility use case to see if we're up to date on the work queue") {
                    subject.presentAlertIfOutOfDateOnController(controller)

                    expect(appVersionCompatibilityUseCase.didCheckVersion) == false

                    workQueue.lastReceivedBlock()

                    expect(appVersionCompatibilityUseCase.didCheckVersion) == true
                }

                describe("when the current version is not supported") {
                    let expectedURL = NSURL(string: "https://example.com/update")!

                    beforeEach {
                        subject.presentAlertIfOutOfDateOnController(controller)
                        workQueue.lastReceivedBlock()
                    }

                    it("presents an alert controller on the main queue") {
                        appVersionCompatibilityUseCase.lastNotSupportedCallback!(expectedURL)

                        resultQueue.lastReceivedBlock()

                        let actionController = controller.presentedViewController as? UIAlertController

                        expect(actionController).notTo(beNil())
                    }

                    describe("alert controller content") {
                        var actionController: UIAlertController?

                        beforeEach {
                            appVersionCompatibilityUseCase.lastNotSupportedCallback!(expectedURL)
                            resultQueue.lastReceivedBlock()

                            actionController = controller.presentedViewController as? UIAlertController
                        }

                        it("has the correct title and message") {
                            expect(actionController?.title) == "Update Required"
                            expect(actionController?.message) == "Please update Connect to the latest version to continue"
                        }

                        it("has one button") {
                            let actions = actionController?.actions
                            expect(actions!.count) == 1

                            let action = actions!.first!

                            expect(action.title) == "Continue"
                        }

                        describe("tapping the button") {
                            pending("opens the URL in safari") {
                                // why no work T_T

                                let action = actionController?.actions.first!

                                action!.handler()

                                expect(urlOpener.lastOpenedURL) === expectedURL
                            }
                        }
                    }
                }
            }
        }
    }
}

private class MockAppVersionCompatibilityUseCase: AppVersionCompatibilityUseCase {
    private var didCheckVersion = false
    private var lastNotSupportedCallback: ((NSURL) -> ())?

    private func checkCurrentAppVersion(currentVersionNotSupported: (updateURL: NSURL) -> ()) {
        didCheckVersion = true
        lastNotSupportedCallback = currentVersionNotSupported
    }
}
