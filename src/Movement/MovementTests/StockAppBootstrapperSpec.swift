import Quick
import Nimble
import AVFoundation

@testable import Movement

class StockAppBootstrapperSpec: QuickSpec {
    override func spec() {
        describe("StockAppBootstrapper") {
            var subject: AppBootstrapper!
            var onboardingWorkflow: FakeOnboardingWorkflow!
            var audioSession: AVAudioSession!
            var theme: FakeTheme!
            var window: FakeUIWindow!

            beforeEach {
                onboardingWorkflow = FakeOnboardingWorkflow()
                audioSession = AVAudioSession()
                theme = AppBootstrapperFakeTheme()
                window = FakeUIWindow()

                subject = StockAppBootstrapper(
                    onboardingWorkflow: onboardingWorkflow,
                    window: window,
                    audioSession: audioSession,
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

                        expect(window.rootViewController).to(beIdenticalTo(expectedController))
                    }

                    it("sets the window's background color from the theme") {
                        onboardingWorkflow.lastInitialViewControllerCompletionHandler(expectedController)

                        expect(window.backgroundColor).to(equal(UIColor.magentaColor()))
                    }

                    it("makes the window key and visible") {
                        onboardingWorkflow.lastInitialViewControllerCompletionHandler(expectedController)

                        expect(window.madeKeyAndVisible).to(beTrue())
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
