import Swinject

class MoreContainerConfigurator: ContainerConfigurator {
    // swiftlint:disable function_body_length
    static func configureContainer(container: Container) {
        container.register(AboutController.self) { resolver in
            return AboutController(
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                theme: resolver.resolve(Theme.self)!
            )
            }.inObjectScope(.Container)

        container.register(AnalyticsSettingsController.self) { resolver in
            return AnalyticsSettingsController(
                applicationSettingsRepository: resolver.resolve(ApplicationSettingsRepository.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!
            )
            }.inObjectScope(.Container)

        container.register(FeedbackController.self) { resolver in
            return FeedbackController(
                urlProvider: resolver.resolve(URLProvider.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!
            )
            }.inObjectScope(.Container)

        container.register(FLOSSController.self) { resolver in
            return FLOSSController(analyticsService: resolver.resolve(AnalyticsService.self)!)
            }.inObjectScope(.Container)

        container.register(PrivacyPolicyController.self) { resolver in
            return PrivacyPolicyController(
                urlProvider: resolver.resolve(URLProvider.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!
            )
            }.inObjectScope(.Container)

        container.register([UIViewController].self, name: "settingsControllers") { resolver in
            return [
                resolver.resolve(AboutController.self)!,
                resolver.resolve(FeedbackController.self)!,
                resolver.resolve(AnalyticsSettingsController.self)!,
                resolver.resolve(PrivacyPolicyController.self)!,
                resolver.resolve(FLOSSController.self)!
            ]
            }.inObjectScope(.Container)

        container.register(SettingsController.self) { resolver in
            return SettingsController(
                tappableControllers: resolver.resolve([UIViewController].self, name: "settingsControllers")!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!
            )
            }.inObjectScope(.Container)
    }
    // swiftlint:enable function_body_length
}
