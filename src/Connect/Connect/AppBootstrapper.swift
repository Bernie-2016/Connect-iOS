import UIKit
import AVFoundation

protocol AppBootstrapper {
    func bootstrap()
}

class StockAppBootstrapper: AppBootstrapper {
    let onboardingWorkflow: OnboardingWorkflow
    let window: UIWindow
    let audioSession: AVAudioSession
    let apiKeyProvider: APIKeyProvider
    let theme: Theme

    init(onboardingWorkflow: OnboardingWorkflow, window: UIWindow, audioSession: AVAudioSession, apiKeyProvider: APIKeyProvider, theme: Theme) {
        self.onboardingWorkflow = onboardingWorkflow
        self.window = window
        self.audioSession = audioSession
        self.apiKeyProvider = apiKeyProvider
        self.theme = theme
    }

    func bootstrap() {
        configureRollbar()
        configureAudioSession()
        startApp()
    }

    // MARK: Private

    private func configureRollbar() {
        #if RELEASE
            let rollbarConfig = RollbarConfiguration()
            #if ACCEPTANCE
            rollbarConfig.environment = "QA"
            #endif
            #if PRODUCTION
            rollbarConfig.environment = "Production"
            #endif
            Rollbar.initWithAccessToken(apiKeyProvider.rollbarAccessToken(), configuration: rollbarConfig)
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
