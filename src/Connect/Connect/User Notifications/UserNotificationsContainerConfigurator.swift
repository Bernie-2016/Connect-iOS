import Swinject
import Parse

class UserNotificationContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        container.register(PushNotificationRegistrar.self) { resolver in
                return ParsePushNotificationRegistrar(installation: resolver.resolve(PFInstallation.self)!)
        }

        container.register(RemoteNotificationHandler.self) { resolver in
            let newsHandler = OpenNewsArticleNotificationHandler(
                newsNavigationController: resolver.resolve(NavigationController.self, name: "news")!,
                interstitialController: resolver.resolve(UIViewController.self, name: "interstitial")!,
                tabBarController: resolver.resolve(TabBarController.self)!,
                newsFeedItemControllerProvider: resolver.resolve(NewsFeedItemControllerProvider.self)!,
                newsArticleService: resolver.resolve(NewsArticleService.self)!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!
            )

            let parseAnalyticsHandler = ParseAnalyticsNotificationHandler(pfAnalyticsProxy: resolver.resolve(PFAnalyticsProxy.self)!)

            let actionAlertHandler = OpenActionAlertNotificationHandler(
                actionsNavigationController: resolver.resolve(NavigationController.self, name: "actions")!,
                tabBarController: resolver.resolve(TabBarController.self)!
            )

            let videoHandler = OpenVideoNotificationHandler(
                newsNavigationController: resolver.resolve(NavigationController.self, name: "news")!,
                interstitialController: resolver.resolve(UIViewController.self, name: "interstitial")!,
                tabBarController: resolver.resolve(TabBarController.self)!,
                newsFeedItemControllerProvider: resolver.resolve(NewsFeedItemControllerProvider.self)!,
                videoService: resolver.resolve(VideoService.self)!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!
            )

            let showNearbyEventsHandler = ShowNearbyEventsNotificationHandler(
                eventsNavigationController: resolver.resolve(NavigationController.self, name: "events")!,
                tabBarController: resolver.resolve(TabBarController.self)!,
                nearbyEventsUseCase: resolver.resolve(NearbyEventsUseCase.self)!,
                radiusDataSource: resolver.resolve(RadiusDataSource.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!
            )

            let voterRegistrationHandler = OpenVoterRegistrationNotificationHandler(
                voterRegistrationController: resolver.resolve(VoterRegistrationController.self)!,
                tabBarController: resolver.resolve(TabBarController.self)!
            )

            let handlers: [RemoteNotificationHandler] = [
                newsHandler,
                videoHandler,
                actionAlertHandler,
                showNearbyEventsHandler,
                voterRegistrationHandler,
                parseAnalyticsHandler
            ]

            return PushNotificationHandlerDispatcher(handlers: handlers)
        }
    }
}
