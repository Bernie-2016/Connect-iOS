import UIKit

public class TabBarController : UITabBarController {
    public var theme : Theme! = DefaultTheme()
    
    public init(theme: Theme, viewControllers: Array<UIViewController>) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
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
}