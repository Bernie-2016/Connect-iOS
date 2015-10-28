import UIKit

class NavigationController: UINavigationController {
    private let theme: Theme

    init(theme: Theme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.theme.defaultBackgroundColor()
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationBar.translucent = false
        self.navigationBar.barTintColor = self.theme.navigationBarBackgroundColor()
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: self.theme.navigationBarTextColor(),
            NSFontAttributeName: self.theme.navigationBarFont()
        ]
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
