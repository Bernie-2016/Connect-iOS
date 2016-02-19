import Swinject

class OnboardingControllerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        container.register(WelcomeController.self) { resolver in
            return WelcomeController(
                applicationSettingsRepository: resolver.resolve(ApplicationSettingsRepository.self)!,
                termsAndConditionsController: resolver.resolve(TermsAndConditionsController.self)!,
                privacyPolicyController: resolver.resolve(PrivacyPolicyController.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!
            )
            }.inObjectScope(.Container)

        container.register(OnboardingWorkflow.self) { resolver in
            let welcomeController = resolver.resolve(WelcomeController.self)!
            let onboardingWorkflow = OnboardingWorkflow(
                applicationSettingsRepository: resolver.resolve(ApplicationSettingsRepository.self)!,
                onboardingController: welcomeController,
                postOnboardingController: resolver.resolve(TabBarController.self)!,
                pushNotificationRegistrar: resolver.resolve(PushNotificationRegistrar.self)!,
                application: resolver.resolve(UserNotificationRegisterable.self)!)

            welcomeController.onboardingWorkflow = onboardingWorkflow

            return onboardingWorkflow

            }.inObjectScope(.Container)
    }
}
