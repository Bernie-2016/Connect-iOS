import UIKit

public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.purpleColor()
        ]
        
        application.statusBarStyle = .LightContent
        
        let mainQueue = NSOperationQueue.mainQueue()
        let sharedURLSession = NSURLSession.sharedSession()
        let defaultTheme = DefaultTheme()
        let urlProvider = ConcreteURLProvider()
        let onoXMLDocumentProvider = ONOXMLDocumentProvider()
        let xmlClient = ConcreteXMLClient(
            urlSession: sharedURLSession,
            onoXMLDocumentProvider: onoXMLDocumentProvider
        )
        
        let newsItemRepository = ConcreteNewsItemRepository()
        let longDateFormatter = NSDateFormatter()
        longDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        
        let newsController = NewsTableViewController(
            theme: defaultTheme,
            newsItemRepository: newsItemRepository,
            dateFormatter: longDateFormatter
        )
        
        let newsNavigationController = NavigationController(theme: defaultTheme)
        newsNavigationController.pushViewController(newsController, animated: false)
        let issueDeserializer = ConcreteIssueDeserializer()
        
        let issueRepository = ConcreteIssueRepository(
            urlProvider: urlProvider,
            xmlClient: xmlClient,
            issueDeserializer: issueDeserializer,
            operationQueue: mainQueue
        )
        
        let issuesController = IssuesTableViewController(
            issueRepository: issueRepository,
            theme: defaultTheme
        )
        let issuesNavigationController = NavigationController(theme: defaultTheme)
        issuesNavigationController.pushViewController(issuesController, animated: false)
        
        let organizeItemRepository = ConcreteOrganizeItemRepository()
        let organizeController = OrganizeTableViewController(
            theme: defaultTheme,
            organizeItemRepository: organizeItemRepository,
            dateFormatter: longDateFormatter
        )
        let organizeNavigationController = NavigationController(theme: defaultTheme)
        organizeNavigationController.pushViewController(organizeController, animated: false)

        
        let connectController = ConnectTableViewController(
            theme: defaultTheme,
            connectItemRepository: ConcreteConnectItemRepository(),
            dateFormatter: longDateFormatter
        )
        let connectNavigationController = NavigationController(theme: defaultTheme)
        connectNavigationController.pushViewController(connectController, animated: false)

        let viewControllers = [
            newsNavigationController,
            issuesNavigationController,
            organizeNavigationController,
            connectNavigationController
        ]
        
        let tabBarController = TabBarController(theme: defaultTheme, viewControllers: viewControllers)
                
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = tabBarController
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()        
        
        return true
    }
}

