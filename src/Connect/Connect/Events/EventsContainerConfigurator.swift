import Swinject
import CoreLocation

class EventsContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        configureUseCases(container)
        configureDataAccess(container)
        configureUI(container)
    }

    private static func configureUseCases(container: Container) {
        container.register(LocationManagerProxy.self) { resolver in
            return StockLocationManagerProxy(locationManager: resolver.resolve(CLLocationManager.self)!)
        }.inObjectScope(.Container)

        container.register(LocationPermissionUseCase.self) { resolver in
            return StockLocationPermissionUseCase(locationManagerProxy: resolver.resolve(LocationManagerProxy.self)!)
        }.inObjectScope(.Container)

        container.register(CurrentLocationUseCase.self) { resolver in
            return StockCurrentLocationUseCase(
                locationManagerProxy: resolver.resolve(LocationManagerProxy.self)!,
                locationPermissionUseCase: resolver.resolve(LocationPermissionUseCase.self)!
            )
        }.inObjectScope(.Container)

        container.register(NearbyEventsUseCase.self) { resolver in
            return StockNearbyEventsUseCase(
                currentLocationUseCase: resolver.resolve(CurrentLocationUseCase.self)!,
                eventRepository: resolver.resolve(EventRepository.self)!)
        }.inObjectScope(.Container)

        container.register(EventsNearAddressUseCase.self) { resolver in
            return StockEventsNearAddressUseCase(
                geocoder: resolver.resolve(CLGeocoder.self)!,
                eventRepository: resolver.resolve(EventRepository.self)!
            )
        }.inObjectScope(.Container)
    }

    private static func configureDataAccess(container: Container) {
        container.register(EventDeserializer.self) { _ in
            return ConcreteEventDeserializer()
            }.inObjectScope(.Container)

        container.register(EventRepository.self) { resolver in
            return ConcreteEventRepository(
                geocoder: resolver.resolve(CLGeocoder.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                jsonClient: resolver.resolve(JSONClient.self)!,
                eventDeserializer: resolver.resolve(EventDeserializer.self)!
            )
            }.inObjectScope(.Container)

        container.register(EventService.self) { resolver in
            return BackgroundEventService(
                eventRepository: resolver.resolve(EventRepository.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!
            )
            }.inObjectScope(.Container)
    }

    // swiftlint:disable function_body_length
    private static func configureUI(container: Container) {
        container.register(EventPresenter.self) { resolver in
            return EventPresenter(
                sameTimeZoneDateFormatter: resolver.resolve(NSDateFormatter.self, name: "time")!,
                differentTimeZoneDateFormatter: resolver.resolve(NSDateFormatter.self, name: "timeWithTimezone")!,
                sameTimeZoneFullDateFormatter: resolver.resolve(NSDateFormatter.self, name: "dateTime")!,
                differentTimeZoneFullDateFormatter: resolver.resolve(NSDateFormatter.self, name: "dateTimeWithTimezone")!
            )
            }.inObjectScope(.Container)

        container.register(EventRSVPControllerProvider.self) { resolver in
            return ConcreteEventRSVPControllerProvider(
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(EventControllerProvider.self) { resolver in
            return ConcreteEventControllerProvider(
                eventPresenter: resolver.resolve(EventPresenter.self)!,
                eventRSVPControllerProvider: resolver.resolve(EventRSVPControllerProvider.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(EventSectionHeaderPresenter.self) { resolver in
            return EventSectionHeaderPresenter(
                currentWeekDateFormatter: resolver.resolve(NSDateFormatter.self, name: "day")!,
                nonCurrentWeekDateFormatter: resolver.resolve(NSDateFormatter.self, name: "shortDate")!,
                dateProvider: resolver.resolve(DateProvider.self)!)
            }.inObjectScope(.Container)

        container.register(EventListTableViewCellStylist.self) { resolver in
            return ConcreteEventListTableViewCellStylist(
                dateProvider: resolver.resolve(DateProvider.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(ZipCodeValidator.self) { resolver in
            return StockZipCodeValidator()
            }.inObjectScope(.Container)

        container.register(EventsController.self) { resolver in
            return EventsController(
                eventService: resolver.resolve(EventService.self)!,
                eventPresenter: resolver.resolve(EventPresenter.self)!,
                eventControllerProvider: resolver.resolve(EventControllerProvider.self)!,
                eventSectionHeaderPresenter: resolver.resolve(EventSectionHeaderPresenter.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!,
                eventListTableViewCellStylist: resolver.resolve(EventListTableViewCellStylist.self)!,
                zipCodeValidator: resolver.resolve(ZipCodeValidator.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(NewEventsController.self) { resolver in
            return NewEventsController(
                searchBarController: resolver.resolve(EventSearchBarController.self)!,
                interstitialController: resolver.resolve(UIViewController.self, name: "interstitial")!,
                resultsController: resolver.resolve(EventsResultsController.self)!,
                errorController: UIViewController(),
                nearbyEventsUseCase: resolver.resolve(NearbyEventsUseCase.self)!,
                eventsNearAddressUseCase: resolver.resolve(EventsNearAddressUseCase.self)!,
                childControllerBuddy: resolver.resolve(ChildControllerBuddy.self)!,
                tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!
            )
            }.inObjectScope(.Container)

        container.register(EventSearchBarController.self) { resolver in
            return EventSearchBarController(
                nearbyEventsUseCase: resolver.resolve(NearbyEventsUseCase.self)!,
                eventsNearAddressUseCase: resolver.resolve(EventsNearAddressUseCase.self)!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!,
                zipCodeValidator: resolver.resolve(ZipCodeValidator.self)!,
                theme: resolver.resolve(Theme.self)!
            )
        }.inObjectScope(.Container)

        container.register(EventsResultsController.self) { resolver in
            return EventsResultsController(
                nearbyEventsUseCase: resolver.resolve(NearbyEventsUseCase.self)!,
                eventsNearAddressUseCase: resolver.resolve(EventsNearAddressUseCase.self)!,
                eventControllerProvider: resolver.resolve(EventControllerProvider.self)!,
                eventPresenter: resolver.resolve(EventPresenter.self)!,
                eventSectionHeaderPresenter: resolver.resolve(EventSectionHeaderPresenter.self)!,
                eventListTableViewCellStylist: resolver.resolve(EventListTableViewCellStylist.self)!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(NavigationController.self, name: "events") { resolver in
            let navigationController = resolver.resolve(NavigationController.self)!
            let eventsController = resolver.resolve(NewEventsController.self)!
            navigationController.pushViewController(eventsController, animated: false)
            return navigationController
        }.inObjectScope(.Container)
    }
    // swiftlint:enable function_body_length
}
