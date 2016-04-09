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

        container.register(ActionAlertWebViewProvider.self) { resolver in
            return StockActionAlertWebViewProvider(urlProvider: resolver.resolve(BaseURLProvider.self)!)
        }

        container.register(ActionAlertsController.self) { resolver in
            return ActionAlertsController(
                actionAlertService: resolver.resolve(ActionAlertService.self)!,
                actionAlertWebViewProvider: resolver.resolve(ActionAlertWebViewProvider.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                moreController: resolver.resolve(SettingsController.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!,
                theme: resolver.resolve(Theme.self)!)
        }

        container.register(NavigationController.self, name: "actions") { resolver in
            let navigationController = resolver.resolve(NavigationController.self)!
            let actionsController = resolver.resolve(ActionAlertsController.self)!
            navigationController.pushViewController(actionsController, animated: false)
            return navigationController
        }
    }
}
