import Foundation
import WebImage
import Parse

#if RELEASE
    import Fabric
    import Crashlytics
#endif

// swiftlint:disable type_body_length

class AppBootstrapper {
    var window: UIWindow?
    var pushNotificationRegistrar: PushNotificationRegistrar!

    // swiftlint:disable function_body_length
    func bootstrapWithApplication(application: UIApplication) -> Bool {
        #if RELEASE
            Fabric.with([Crashlytics.self()])
        #endif

        let defaultTheme = DefaultTheme()

        UITabBar.appearance().tintColor = defaultTheme.tabBarActiveTextColor()
        UITabBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = defaultTheme.navigationBarTextColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: defaultTheme.navigationBarFont(), NSForegroundColorAttributeName: defaultTheme.navigationBarTextColor()], forState: UIControlState.Normal)

        let apiKeyProvider = APIKeyProvider()

        let dateProvider = ConcreteDateProvider()
        let mainQueue = NSOperationQueue.mainQueue()
        let mainScreen = UIScreen.mainScreen()
        let sharedURLSession = NSURLSession.sharedSession()
        let applicationSettingsRepository = ConcreteApplicationSettingsRepository(
            userDefaults: NSUserDefaults.standardUserDefaults())

        let tabBarItemStylist = ConcreteTabBarItemStylist(theme: defaultTheme)

        Parse.setApplicationId(apiKeyProvider.parseApplicationId(), clientKey: apiKeyProvider.parseClientKey())
        self.pushNotificationRegistrar = ConcretePushNotificationRegistrar(installation: PFInstallation.currentInstallation())

        let analyticsService = ConcreteAnalyticsService(
            applicationSettingsRepository: applicationSettingsRepository,
            apiKeyProvider: apiKeyProvider
        )
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


        let newsArticleDeserializer = ConcreteNewsArticleDeserializer(stringContentSanitizer: stringContentSanitizer)
        let newsArticleRepository = ConcreteNewsArticleRepository(
            urlProvider: urlProvider,
            jsonClient: jsonClient,
            newsArticleDeserializer: newsArticleDeserializer,
            operationQueue: mainQueue
        )

        let timeIntervalFormatter = ConcreteTimeIntervalFormatter(dateProvider: dateProvider)
        let longDateFormatter = NSDateFormatter()
        longDateFormatter.dateStyle = .LongStyle
        let dateTimeFormatter =  NSDateFormatter()
        dateTimeFormatter.dateFormat = "EEEE MMMM d, hh:mma"
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mma"
        let timeWithTimeZoneFormatter = NSDateFormatter()
        timeWithTimeZoneFormatter.dateFormat = "hh:mma v"
        let dateTimeWithTimeZoneFormatter = NSDateFormatter()
        dateTimeWithTimeZoneFormatter.dateFormat = "EEEE MMMM d, hh:mma v"

        let dayDateFormatter = NSDateFormatter()
        dayDateFormatter.dateFormat = "EEEE"
        let shortDateFormatter = NSDateFormatter()
        shortDateFormatter.dateStyle = .ShortStyle


        let newsFeedItemControllerProvider = ConcreteNewsFeedItemControllerProvider(
            timeIntervalFormatter: timeIntervalFormatter,
            imageRepository: imageRepository,
            analyticsService: analyticsService,
            urlOpener: urlOpener,
            urlAttributionPresenter: urlAttributionPresenter,
            urlProvider: urlProvider,
            theme: defaultTheme
        )

        let videoDeserializer = ConcreteVideoDeserializer()
        let videoRepository = ConcreteVideoRepository(
            urlProvider: urlProvider,
            jsonClient: jsonClient,
            videoDeserializer: videoDeserializer,
            operationQueue: mainQueue)

        let newsFeedService = ConcreteNewsFeedService(newsArticleRepository: newsArticleRepository, videoRepository: videoRepository)
        let newsFeedArticlePresenter = NewsFeedArticlePresenter(timeIntervalFormatter: timeIntervalFormatter, imageRepository: imageRepository, theme: defaultTheme)
        let newsFeedVideoPresenter = NewsFeedVideoPresenter()
        let newsFeedTableViewCellPresenter = ConcreteNewsFeedTableViewCellPresenter(articlePresenter: newsFeedArticlePresenter, videoPresenter: newsFeedVideoPresenter)

        let newsFeedController = NewsFeedController(
            newsFeedService: newsFeedService,
            newsFeedItemControllerProvider: newsFeedItemControllerProvider,
            newsFeedTableViewCellPresenter: newsFeedTableViewCellPresenter,
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

        let eventDeserializer = ConcreteEventDeserializer(stringContentSanitizer: stringContentSanitizer)
        let eventRepository = ConcreteEventRepository(
            geocoder: CLGeocoder(),
            urlProvider: urlProvider,
            jsonClient: jsonClient,
            eventDeserializer: eventDeserializer,
            operationQueue: mainQueue)
        let eventPresenter = EventPresenter(
            sameTimeZoneDateFormatter: timeFormatter,
            differentTimeZoneDateFormatter: timeWithTimeZoneFormatter,
            sameTimeZoneFullDateFormatter: dateTimeFormatter,
            differentTimeZoneFullDateFormatter: dateTimeWithTimeZoneFormatter)
        let eventRSVPControllerProvider = ConcreteEventRSVPControllerProvider(analyticsService: analyticsService, theme: defaultTheme)
        let eventControllerProvider = ConcreteEventControllerProvider(
            eventPresenter: eventPresenter,
            eventRSVPControllerProvider: eventRSVPControllerProvider,
            urlProvider: urlProvider,
            urlOpener: urlOpener,
            analyticsService: analyticsService,
            theme: defaultTheme)

        let eventSectionHeaderPresenter = EventSectionHeaderPresenter(
            currentWeekDateFormatter: dayDateFormatter,
            nonCurrentWeekDateFormatter: shortDateFormatter,
            dateProvider: dateProvider)

        let eventListTableViewCellStylist = ConcreteEventListTableViewCellStylist(dateProvider: dateProvider, theme: defaultTheme)
        let eventsController = EventsController(
            eventRepository: eventRepository,
            eventPresenter: eventPresenter,
            eventControllerProvider: eventControllerProvider,
            eventSectionHeaderPresenter: eventSectionHeaderPresenter,
            urlProvider: urlProvider,
            urlOpener: urlOpener,
            analyticsService: analyticsService,
            tabBarItemStylist: tabBarItemStylist,
            eventListTableViewCellStylist: eventListTableViewCellStylist,
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

        let onboardingWorkflow = OnboardingWorkflow(
            applicationSettingsRepository: applicationSettingsRepository,
            onboardingController: welcomeNavigationController,
            postOnboardingController: tabBarController,
            pushNotificationRegistrar: pushNotificationRegistrar,
            application: application
        )

        welcomeController.onboardingWorkflow = onboardingWorkflow

        onboardingWorkflow.initialViewController { (controller) -> Void in
            self.window = UIWindow(frame: mainScreen.bounds)
            self.window!.rootViewController = controller
            self.window!.backgroundColor = defaultTheme.defaultBackgroundColor()
            self.window!.makeKeyAndVisible()
        }

        return true
    }
    // swiftlint:enable function_body_length
}
// swiftlint:enable type_body_length
