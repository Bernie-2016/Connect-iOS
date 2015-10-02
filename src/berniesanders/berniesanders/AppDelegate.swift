import UIKit
import WebImage

#if RELEASE
import Fabric
import Crashlytics
#endif

public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [NSObject: AnyObject]?) -> Bool {

            #if RELEASE
                Fabric.with([Crashlytics.self()])
            #endif
            
            let mainQueue = NSOperationQueue.mainQueue()
            let sharedURLSession = NSURLSession.sharedSession()
            let analyticsService = ConcreteAnalyticsService()
            
            let defaultTheme = DefaultTheme()
            let urlProvider = ConcreteURLProvider()
            let jsonSerializerProvider = NSJSONSerializationProvider()
            let jsonClient = ConcreteJSONClient(
                urlSession: sharedURLSession,
                jsonSerializationProvider: jsonSerializerProvider
            )
            
            let webImageManager = SDWebImageManager()
            let imageRepository = ConcreteImageRepository(webImageManager: webImageManager)
            
            let privacyPolicyController = PrivacyPolicyController(urlProvider: urlProvider)
            let flossController = FLOSSController()
            let settingsController = SettingsController(
                tappableControllers: [privacyPolicyController, flossController],
                theme: defaultTheme)
            
            let newsItemDeserializer = ConcreteNewsItemDeserializer()
            let newsItemRepository = ConcreteNewsItemRepository(
                urlProvider: urlProvider,
                jsonClient: jsonClient,
                newsItemDeserializer: newsItemDeserializer,
                operationQueue: mainQueue
            )
            let longDateFormatter = NSDateFormatter()
            longDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            let fullDateWithTimeFormatter = NSDateFormatter()
            fullDateWithTimeFormatter.dateFormat = "EEEE MMMM d, y h:mm a z"
            
            let newsItemControllerProvider = ConcreteNewsItemControllerProvider(
                dateFormatter: longDateFormatter, imageRepository: imageRepository, analyticsService: analyticsService, theme: defaultTheme
            )
            
            let newsFeedController = NewsFeedController(
                newsItemRepository: newsItemRepository,
                imageRepository: imageRepository,
                dateFormatter: longDateFormatter,
                newsItemControllerProvider: newsItemControllerProvider,
                settingsController: settingsController,
                analyticsService: analyticsService,
                theme: defaultTheme
            )
            
            let newsNavigationController = NavigationController(theme: defaultTheme)
            newsNavigationController.pushViewController(newsFeedController, animated: false)
            let issueDeserializer = ConcreteIssueDeserializer()
            
            let issueRepository = ConcreteIssueRepository(
                urlProvider: urlProvider,
                jsonClient: jsonClient,
                issueDeserializer: issueDeserializer,
                operationQueue: mainQueue
            )
            
            let issueControllerProvider = ConcreteIssueControllerProvider(imageRepository: imageRepository, theme: defaultTheme)
            
            let issuesTableController = IssuesController(
                issueRepository: issueRepository,
                issueControllerProvider: issueControllerProvider,
                settingsController: settingsController,
                theme: defaultTheme
            )
            let issuesNavigationController = NavigationController(theme: defaultTheme)
            issuesNavigationController.pushViewController(issuesTableController, animated: false)
            
            let organizeController = OrganizeController(urlProvider: urlProvider,
                theme: defaultTheme)
            
            let eventDeserializer = ConcreteEventDeserializer()
            let eventRepository = ConcreteEventRepository(
                geocoder: CLGeocoder(),
                urlProvider: urlProvider,
                jsonClient: jsonClient,
                eventDeserializer: eventDeserializer,
                operationQueue: mainQueue)
            let eventPresenter = EventPresenter(dateFormatter: fullDateWithTimeFormatter)
            let urlOpener = URLOpener()
            let eventRSVPControllerProvider = ConcreteEventRSVPControllerProvider(theme: defaultTheme)
            let eventControllerProvider = ConcreteEventControllerProvider(
                eventPresenter: eventPresenter,
                eventRSVPControllerProvider: eventRSVPControllerProvider,
                urlProvider: urlProvider,
                urlOpener: urlOpener,
                theme: defaultTheme)
            let eventsController = EventsController(
                eventRepository: eventRepository,
                eventPresenter: eventPresenter,
                settingsController: settingsController,
                eventControllerProvider: eventControllerProvider,
                theme: defaultTheme
            )
            let eventsNavigationController = NavigationController(theme: defaultTheme)
            eventsNavigationController.pushViewController(eventsController, animated: false)
            
            let tabBarViewControllers = [
                newsNavigationController,
                issuesNavigationController,
                eventsNavigationController,
                organizeController
            ]
            
            let tabBarController = TabBarController(viewControllers: tabBarViewControllers, analyticsService: analyticsService, theme: defaultTheme)
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window!.rootViewController = tabBarController
            self.window!.backgroundColor = defaultTheme.defaultBackgroundColor()
            self.window!.makeKeyAndVisible()
            
            UITabBar.appearance().tintColor = defaultTheme.tabBarActiveTextColor()
            UINavigationBar.appearance().tintColor = defaultTheme.navigationBarTextColor()
            UIBarButtonItem.appearance().setTitleTextAttributes([
                NSFontAttributeName: defaultTheme.navigationBarFont(), NSForegroundColorAttributeName: defaultTheme.navigationBarTextColor()], forState: UIControlState.Normal)
            
            
            return true
    }
}

