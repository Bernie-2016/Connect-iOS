import UIKit
import WebImage

#if RELEASE
import Fabric
import Crashlytics
#endif

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // swiftlint:disable function_body_length
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            #if RELEASE
                Fabric.with([Crashlytics.self()])
            #endif

            let defaultTheme = DefaultTheme()

            UITabBar.appearance().tintColor = defaultTheme.tabBarActiveTextColor()
            UITabBar.appearance().translucent = false
            UINavigationBar.appearance().tintColor = defaultTheme.navigationBarTextColor()
            UIBarButtonItem.appearance().setTitleTextAttributes([
                NSFontAttributeName: defaultTheme.navigationBarFont(), NSForegroundColorAttributeName: defaultTheme.navigationBarTextColor()], forState: UIControlState.Normal)


            let dateProvider = ConcreteDateProvider()
            let mainQueue = NSOperationQueue.mainQueue()
            let mainScreen = UIScreen.mainScreen()
            let sharedURLSession = NSURLSession.sharedSession()
            let applicationSettingsRepository = ConcreteApplicationSettingsRepository(
                userDefaults: NSUserDefaults.standardUserDefaults())

            let tabBarItemStylist = ConcreteTabBarItemStylist(theme: defaultTheme)

            let analyticsService = ConcreteAnalyticsService(applicationSettingsRepository: applicationSettingsRepository)
            let stringContentSanitizer = ConcreteStringContentSanitizer()

            let urlProvider = ConcreteURLProvider()
            let urlOpener = URLOpener()
            let urlAttributionPresenter = ConcreteURLAttributionPresenter()

            let jsonSerializerProvider = NSJSONSerializationProvider()
            let jsonClient = ConcreteJSONClient(
                urlSession: sharedURLSession,
                jsonSerializationProvider: jsonSerializerProvider
            )

            let webImageManager = SDWebImageManager()
            let imageRepository = ConcreteImageRepository(webImageManager: webImageManager)

            let aboutController = AboutController(analyticsService: analyticsService, urlOpener: urlOpener, urlProvider: urlProvider, theme: defaultTheme)
            let feedbackController = FeedbackController(urlProvider: urlProvider, analyticsService: analyticsService)
            let privacyPolicyController = PrivacyPolicyController(urlProvider: urlProvider, analyticsService: analyticsService)
            let flossController = FLOSSController(analyticsService: analyticsService)
            let termsAndConditionsController = TermsAndConditionsController(analyticsService: analyticsService)
            let analyticsSettingsController = AnalyticsSettingsController(applicationSettingsRepository: applicationSettingsRepository, analyticsService: analyticsService, theme: defaultTheme)
            let settingsController = SettingsController(
                tappableControllers: [aboutController, feedbackController, analyticsSettingsController, termsAndConditionsController, privacyPolicyController, flossController],
                urlOpener: urlOpener,
                urlProvider: urlProvider,
                analyticsService: analyticsService,
                tabBarItemStylist: tabBarItemStylist,
                theme: defaultTheme)
        let settingsNavigationController = NavigationController(theme: defaultTheme)
        settingsNavigationController.pushViewController(settingsController, animated: false)


            let newsItemDeserializer = ConcreteNewsItemDeserializer(stringContentSanitizer: stringContentSanitizer)
            let newsItemRepository = ConcreteNewsItemRepository(
                urlProvider: urlProvider,
                jsonClient: jsonClient,
                newsItemDeserializer: newsItemDeserializer,
                operationQueue: mainQueue
            )

        let humanTimeIntervalFormatter = ConcreteHumanTimeIntervalFormatter(dateProvider: dateProvider)
            let longDateFormatter = NSDateFormatter()
            longDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            let fullDateWithTimeFormatter = NSDateFormatter()
            fullDateWithTimeFormatter.dateFormat = "EEEE MMMM d, y h:mm a z"

            let newsItemControllerProvider = ConcreteNewsItemControllerProvider(
                humanTimeIntervalFormatter: humanTimeIntervalFormatter, imageRepository: imageRepository, analyticsService: analyticsService, urlOpener: urlOpener, urlAttributionPresenter: urlAttributionPresenter, theme: defaultTheme
            )

            let newsFeedController = NewsFeedController(
                newsItemRepository: newsItemRepository,
                imageRepository: imageRepository,
                dateFormatter: longDateFormatter,
                newsItemControllerProvider: newsItemControllerProvider,
                analyticsService: analyticsService,
                tabBarItemStylist: tabBarItemStylist,
                theme: defaultTheme
            )

            let newsNavigationController = NavigationController(theme: defaultTheme)
            newsNavigationController.pushViewController(newsFeedController, animated: false)
            let issueDeserializer = ConcreteIssueDeserializer(stringContentSanitizer: stringContentSanitizer)

            let issueRepository = ConcreteIssueRepository(
                urlProvider: urlProvider,
                jsonClient: jsonClient,
                issueDeserializer: issueDeserializer,
                operationQueue: mainQueue
            )

            let issueControllerProvider = ConcreteIssueControllerProvider(imageRepository: imageRepository,
                analyticsService: analyticsService,
                urlOpener: urlOpener,
                urlAttributionPresenter: urlAttributionPresenter,
                theme: defaultTheme)

            let issuesTableController = IssuesController(
                issueRepository: issueRepository,
                issueControllerProvider: issueControllerProvider,
                analyticsService: analyticsService,
                tabBarItemStylist: tabBarItemStylist,
                theme: defaultTheme
            )
            let issuesNavigationController = NavigationController(theme: defaultTheme)
            issuesNavigationController.pushViewController(issuesTableController, animated: false)

            let eventDeserializer = ConcreteEventDeserializer()
            let eventRepository = ConcreteEventRepository(
                geocoder: CLGeocoder(),
                urlProvider: urlProvider,
                jsonClient: jsonClient,
                eventDeserializer: eventDeserializer,
                operationQueue: mainQueue)
            let eventPresenter = EventPresenter(dateFormatter: fullDateWithTimeFormatter)
            let eventRSVPControllerProvider = ConcreteEventRSVPControllerProvider(analyticsService: analyticsService, theme: defaultTheme)
            let eventControllerProvider = ConcreteEventControllerProvider(
                eventPresenter: eventPresenter,
                eventRSVPControllerProvider: eventRSVPControllerProvider,
                urlProvider: urlProvider,
                urlOpener: urlOpener,
                analyticsService: analyticsService,
                theme: defaultTheme)
            let eventsController = EventsController(
                eventRepository: eventRepository,
                eventPresenter: eventPresenter,
                eventControllerProvider: eventControllerProvider,
                analyticsService: analyticsService,
                tabBarItemStylist: tabBarItemStylist,
                theme: defaultTheme
            )
            let eventsNavigationController = NavigationController(theme: defaultTheme)
            eventsNavigationController.pushViewController(eventsController, animated: false)

            let tabBarViewControllers = [
                eventsNavigationController,
                newsNavigationController,
                issuesNavigationController,
                settingsNavigationController
            ]

            let tabBarController = TabBarController(viewControllers: tabBarViewControllers, analyticsService: analyticsService, theme: defaultTheme)
            tabBarController.selectedIndex = 1
            let rawSelectedTabBarBackground = UIImage(named: "selectedTabBarBackground")!
            let croppedSelectedTabBarBackgroundImageRef = CGImageCreateWithImageInRect(rawSelectedTabBarBackground.CGImage, CGRect(x: 0, y: 0, width: mainScreen.bounds.width / CGFloat(tabBarViewControllers.count), height: 49))
            let croppedSelectedTabBarBackground = UIImage(CGImage:croppedSelectedTabBarBackgroundImageRef!)
            UITabBar.appearance().selectionIndicatorImage = croppedSelectedTabBarBackground


            let welcomeController = WelcomeController(
                applicationSettingsRepository: applicationSettingsRepository,
                termsAndConditionsController: termsAndConditionsController,
                privacyPolicyController: privacyPolicyController,
                analyticsService: analyticsService,
                theme: defaultTheme)
            let welcomeNavigationController = NavigationController(theme: defaultTheme)
            welcomeNavigationController.pushViewController(welcomeController, animated: false)

            let onboardingRouter = OnboardingRouter(
                applicationSettingsRepository: applicationSettingsRepository,
                onboardingController: welcomeNavigationController,
                postOnboardingController: tabBarController)

            welcomeController.onboardingRouter = onboardingRouter

            onboardingRouter.initialViewController { (controller) -> Void in
                self.window = UIWindow(frame: mainScreen.bounds)
                self.window!.rootViewController = controller
                self.window!.backgroundColor = defaultTheme.defaultBackgroundColor()
                self.window!.makeKeyAndVisible()
            }


            return true
    }
    // swiftlint:enable function_body_length
}
