import Swinject

class GlobalUIContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        container.register(TabBarItemStylist.self) { resolver in
            return ConcreteTabBarItemStylist(theme: resolver.resolve(Theme.self)!)
        }.inObjectScope(.Container)

        container.register(TimeIntervalFormatter.self) { resolver in
                return ConcreteTimeIntervalFormatter(dateProvider: resolver.resolve(DateProvider.self)!)
        }.inObjectScope(.Container)

        container.register(UIViewController.self, name: "interstitial") { resolver in
                return InterstitialController(theme: resolver.resolve(Theme.self)!)
        }.inObjectScope(.Container)

        container.register(URLAttributionPresenter.self) { _ in
                return ConcreteURLAttributionPresenter()
        }.inObjectScope(.Container)

        container.register(NavigationController.self) { resolver in
            return NavigationController(theme: resolver.resolve(Theme.self)!)
        }.inObjectScope(.None)

        container.register([UIViewController].self, name: "tabBarControllers") { resolver in
            let controllers = [
                resolver.resolve(NavigationController.self, name: "news")!,
                resolver.resolve(NavigationController.self, name: "events")!,
                resolver.resolve(NavigationController.self, name: "actions")!,
                resolver.resolve(NavigationController.self, name: "more")!,
            ]

            return controllers
        }

        container.register(TabBarController.self) { resolver in
                return TabBarController(
                    viewControllers: resolver.resolve([UIViewController].self, name: "tabBarControllers")!,
                    analyticsService: resolver.resolve(AnalyticsService.self)!,
                    theme: resolver.resolve(Theme.self)!)
        }.inObjectScope(.Container)

        container.register(TimeIntervalFormatter.self) { resolver in
            return ConcreteTimeIntervalFormatter(dateProvider: resolver.resolve(DateProvider.self)!)
        }.inObjectScope(.Container)

        container.register(MarkdownConverter.self) { resolver in
            return CMMarkdownConverter(theme: resolver.resolve(Theme.self)!)
        }.inObjectScope(.None)
    }
}
