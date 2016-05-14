import Swinject

class RegistrationContainerConfigurator: ContainerConfigurator {
    class func configureContainer(container: Container) {
        container.register(UpcomingVoterRegistrationUseCase.self) { resolver in
            return StockUpcomingVoterRegistrationUseCase()
        }

        container.register(VoterRegistrationController.self) { resolver in
            return VoterRegistrationController(
                upcomingVoterRegistrationUseCase: resolver.resolve(UpcomingVoterRegistrationUseCase.self)!,
                tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!)
        }
    }
}
