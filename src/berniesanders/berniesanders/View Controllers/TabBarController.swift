import UIKit

public class TabBarController : UITabBarController, UITabBarControllerDelegate {
    let theme : Theme!
    let analyticsService : AnalyticsService!
    
    public init(viewControllers: Array<UIViewController>, analyticsService: AnalyticsService, theme: Theme) {
        self.analyticsService = analyticsService
        self.theme = theme
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewControllers = viewControllers
        self.delegate = self
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = self.theme.tabBarTintColor()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.analyticsService.trackCustomEventWithName("Tapped \"\(viewController.tabBarItem.title!)\" on tab bar")
    }
}