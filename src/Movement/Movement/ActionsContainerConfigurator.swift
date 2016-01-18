import Swinject

class ActionsContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        container.register(ActionsController.self) { resolver in
            return ActionsController(
                urlProvider: resolver.resolve(URLProvider.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(NavigationController.self, name: "actions") { resolver in
            let navigationController = resolver.resolve(NavigationController.self)!
            let newsFeedController = resolver.resolve(ActionsController.self)!
            navigationController.pushViewController(newsFeedController, animated: false)
            return navigationController
        }
    }
}
