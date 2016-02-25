import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    private let theme: Theme
    private let analyticsService: AnalyticsService

    init(viewControllers: Array<UIViewController>, analyticsService: AnalyticsService, theme: Theme) {
        self.analyticsService = analyticsService
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        self.viewControllers = viewControllers
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.translucent = false
        tabBar.barTintColor = self.theme.tabBarTintColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let title = viewController.tabBarItem.title!
        self.analyticsService.trackContentViewWithName(title, type: .TabBar, identifier: title)
    }
}
