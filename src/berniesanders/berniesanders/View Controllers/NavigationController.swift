import UIKit

public class NavigationController : UINavigationController {
    private let theme : Theme
    
    public init(theme: Theme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)        
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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