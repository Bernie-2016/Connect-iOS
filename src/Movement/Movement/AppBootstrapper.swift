import UIKit
import AVFoundation

class AppBootstrapper {
    let onboardingWorkflow: OnboardingWorkflow
    let window: UIWindow
    let audioSession: AVAudioSession
    let theme: Theme

    init(onboardingWorkflow: OnboardingWorkflow, window: UIWindow, audioSession: AVAudioSession, theme: Theme) {
        self.onboardingWorkflow = onboardingWorkflow
        self.window = window
        self.audioSession = audioSession
        self.theme = theme
    }

    func bootstrap() {
        configureFabric()
        configureAudioSession()
        startApp()
    }

    // MARK: Private

    private func configureFabric() {
        #if RELEASE
            Fabric.with([Crashlytics.self()])
        #endif
    }

    private func configureAudioSession() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            NSLog("Error setting audio category")
        }
    }

    private func startApp() {
        onboardingWorkflow.initialViewController { controller in
            self.window.rootViewController = controller
            self.window.backgroundColor = self.theme.defaultBackgroundColor()
            self.window.makeKeyAndVisible()
        }
    }
}
