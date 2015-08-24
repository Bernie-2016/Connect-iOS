import UIKit

public class NavigationController : UINavigationController {
    public var theme : Theme! = DefaultTheme()
    
    public init(theme: Theme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)        
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = self.theme.navigationBarBackgroundColor()
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: self.theme.navigationBarTextColor(),
            NSFontAttributeName: self.theme.navigationBarFont()
        ]
    }

}