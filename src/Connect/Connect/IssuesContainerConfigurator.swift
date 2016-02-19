import Swinject

class IssuesContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        container.register(IssueDeserializer.self) { resolver in
                return ConcreteIssueDeserializer()
        }.inObjectScope(.Container)

        container.register(IssueRepository.self) { resolver in
                return ConcreteIssueRepository(
                    urlProvider: resolver.resolve(URLProvider.self)!,
                    jsonClient: resolver.resolve(JSONClient.self)!,
                    issueDeserializer: resolver.resolve(IssueDeserializer.self)!)
        }.inObjectScope(.Container)

        container.register(IssueService.self) { resolver in
            return BackgroundIssueService(
                issueRepository: resolver.resolve(IssueRepository.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!
            )
        }.inObjectScope(.Container)

        container.register(IssueControllerProvider.self) { resolver in
            return ConcreteIssueControllerProvider(
                imageService: resolver.resolve(ImageService.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                urlAttributionPresenter: resolver.resolve(URLAttributionPresenter.self)!,
                theme: resolver.resolve(Theme.self)!
            )
        }.inObjectScope(.Container)

        container.register(IssuesController.self) { resolver in
                return IssuesController(
                    issueService: resolver.resolve(IssueService.self)!,
                    issueControllerProvider: resolver.resolve(IssueControllerProvider.self)!,
                    analyticsService: resolver.resolve(AnalyticsService.self)!,
                    tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!,
                    mainQueue: resolver.resolve(NSOperationQueue.self, name: "main")!,
                    theme: resolver.resolve(Theme.self)!)
        }.inObjectScope(.Container)

        container.register(NavigationController.self, name: "issues") { resolver in
            let navigationController = resolver.resolve(NavigationController.self)!
            let issuesController = resolver.resolve(IssuesController.self)!
            navigationController.pushViewController(issuesController, animated: false)
            return navigationController
        }.inObjectScope(.Container)
    }
}
