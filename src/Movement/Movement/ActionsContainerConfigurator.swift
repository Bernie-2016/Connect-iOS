import Swinject

class ActionsContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        container.register(ActionAlertDeserializer.self) { resolver in
            StockActionAlertDeserializer()
        }

        container.register(ActionAlertRepository.self) { resolver in
            StockActionAlertRepository(
                jsonClient: resolver.resolve(JSONClient.self)!,
                actionAlertDeserializer:  resolver.resolve(ActionAlertDeserializer.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!
            )
        }

        container.register(ActionAlertService.self) { resolver in
            BackgroundActionAlertService(
                actionAlertRepository: resolver.resolve(ActionAlertRepository.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!
            )
        }.inObjectScope(.Container)

        container.register(ActionsController.self) { resolver in
            return ActionsController(
                urlProvider: resolver.resolve(URLProvider.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                actionAlertService: resolver.resolve(ActionAlertService.self)!,
                actionAlertControllerProvider: container,
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

extension Container: ActionAlertControllerProvider {
    func provideInstanceWithActionAlert(actionAlert: ActionAlert) -> ActionAlertController {
        return ActionAlertController(
            actionAlert: actionAlert,
            markdownConverter: resolve(MarkdownConverter.self)!,
            urlOpener: resolve(URLOpener.self)!,
            urlProvider: resolve(URLProvider.self)!,
            theme: resolve(Theme.self)!
        )
    }
}
