import Quick
import Nimble
import AVFoundation

@testable import Connect

class StockAppBootstrapperSpec: QuickSpec {
    override func spec() {
        describe("StockAppBootstrapper") {
            var subject: AppBootstrapper!
            var onboardingWorkflow: FakeOnboardingWorkflow!
            var audioSession: AVAudioSession!
            var theme: FakeTheme!
            var window: FakeUIWindow!
            let apiKeyProvider = APIKeyProvider()
            var newVersionNotifier: MockNewVersionNotifier!

            beforeEach {
                onboardingWorkflow = FakeOnboardingWorkflow()
                audioSession = AVAudioSession()
                theme = AppBootstrapperFakeTheme()
                window = FakeUIWindow()
                newVersionNotifier = MockNewVersionNotifier()

                subject = StockAppBootstrapper(
                    onboardingWorkflow: onboardingWorkflow,
                    window: window,
                    audioSession: audioSession,
                    apiKeyProvider: apiKeyProvider,
                    newVersionNotifier: newVersionNotifier,
                    theme: theme
                )
            }

            describe("bootstrap") {
                it("configures the audio session so that sound will play with the phone is in vibrate only mode") {
                    subject.bootstrap()

                    expect(audioSession.category).to(equal(AVAudioSessionCategoryPlayback))
                }

                it("asks the onboarding workflow to provide the initial view controller") {
                    subject.bootstrap()

                    expect(onboardingWorkflow.lastInitialViewControllerCompletionHandler).toNot(beNil())
                }

                context("when the onboarding workflow finishes") {
                    beforeEach { subject.bootstrap() }
                    let expectedController = UIViewController()

                    it("sets the root view controller to be the controller from the workflow") {
                        onboardingWorkflow.lastInitialViewControllerCompletionHandler(expectedController)

                        expect(window.rootViewController) === expectedController
                    }

                    it("sets the window's background color from the theme") {
                        onboardingWorkflow.lastInitialViewControllerCompletionHandler(expectedController)

                        expect(window.backgroundColor) == UIColor.magentaColor()
                    }

                    it("makes the window key and visible") {
                        onboardingWorkflow.lastInitialViewControllerCompletionHandler(expectedController)

                        expect(window.madeKeyAndVisible) == true
                    }

                    it("tells the new version notifier to notify the user of new versions on the controller from the workflow") {
                        onboardingWorkflow.lastInitialViewControllerCompletionHandler(expectedController)

                        expect(newVersionNotifier.lastController) === expectedController
                    }
                }
            }
        }
    }
}

private class AppBootstrapperFakeTheme: FakeTheme {
    private override func defaultBackgroundColor() -> UIColor {
        return UIColor.magentaColor()
    }
}

private class FakeUIWindow: UIWindow {
    var madeKeyAndVisible = false
    private override func makeKeyAndVisible() {
        madeKeyAndVisible = true
    }
}

private class MockNewVersionNotifier: NewVersionNotifier {
    var lastController: UIViewController?

    func presentAlertIfOutOfDateOnController(controller: UIViewController) {
        lastController = controller
    }
}
