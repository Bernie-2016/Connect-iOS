import Swinject
import CoreLocation
import WebImage
import Parse
import Swinject

class MovementContainerProvider {
    static func container(application: UIApplication) -> Container {
        let container = Container()

        container.register(NSUserDefaults.self) { resolver in
            return NSUserDefaults.standardUserDefaults()
            }.inObjectScope(.Container)

        container.register(Theme.self) { resolver in
            return DefaultTheme()
            }.inObjectScope(.Container)

        container.register(NSOperationQueue.self, name: "work") { _ in
            return NSOperationQueue()
            }.inObjectScope(.None)

        container.register(NSOperationQueue.self, name: "main") { _ in
            return NSOperationQueue.mainQueue()
            }.inObjectScope(.Container)

        container.register(CLGeocoder.self) { _ in
            return CLGeocoder()
            }.inObjectScope(.Container)

        container.register(NSURLSession.self, name: "shared") { _ in
            return NSURLSession.sharedSession()
            }.inObjectScope(.Container)

        container.register(SDWebImageManager.self) { _ in
            return SDWebImageManager()
        }.inObjectScope(.Container)

        container.register(UserNotificationRegisterable.self) { _ in application }.inObjectScope(.Container)

        container.register(PFInstallation.self) { resolver in
            let apiKeyProvider = resolver.resolve(APIKeyProvider.self)!
            Parse.setApplicationId(
                apiKeyProvider.parseApplicationId(),
                clientKey: apiKeyProvider.parseClientKey()
            )

            return PFInstallation.currentInstallation()
        }.inObjectScope(.Container)

        container.register(UIScreen.self, name: "main") { _ in
            return UIScreen.mainScreen()
        }.inObjectScope(.Container)

        configureDateFormatters(container)

        return container
    }

    private static func configureDateFormatters(container: Container) {
        container.register(NSDateFormatter.self, name: "time") { _ in
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "hh:mma"
            return timeFormatter
            }.inObjectScope(.Container)

        container.register(NSDateFormatter.self, name: "timeWithTimezone") { _ in
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "hh:mma v"
            return timeFormatter
            }.inObjectScope(.Container)

        container.register(NSDateFormatter.self, name: "dateTime") { _ in
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "EEEE MMMM d, hh:mma"
            return timeFormatter
            }.inObjectScope(.Container)

        container.register(NSDateFormatter.self, name: "dateTimeWithTimezone") { _ in
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "EEEE MMMM d, hh:mma v"
            return timeFormatter
            }.inObjectScope(.Container)

        container.register(NSDateFormatter.self, name: "day") { _ in
            let dayDateFormatter = NSDateFormatter()
            dayDateFormatter.dateFormat = "EEEE"
            return dayDateFormatter
            }.inObjectScope(.Container)

        container.register(NSDateFormatter.self, name: "shortDate") { _ in
            let shortDateFormatter = NSDateFormatter()
            shortDateFormatter.dateStyle = .ShortStyle
            return shortDateFormatter
            }.inObjectScope(.Container)
    }
}
