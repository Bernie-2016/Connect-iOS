import UIKit
import AMScrollingNavbar

class NavigationController: ScrollingNavigationController {
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

        view.backgroundColor = theme.defaultBackgroundColor()

        setNeedsStatusBarAppearanceUpdate()
        navigationBar.translucent = false
        navigationBar.barTintColor = theme.navigationBarBackgroundColor()
        navigationBar.tintColor = theme.navigationBarTintColor()
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: theme.navigationBarTextColor(),
            NSFontAttributeName: theme.navigationBarFont()
        ]

        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSForegroundColorAttributeName: theme.navigationBarButtonTextColor(),
            NSFontAttributeName: theme.navigationBarButtonFont()], forState: .Normal
        )

        navigationBar.backIndicatorImage = UIImage(named: "BackArrow")
        navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "BackArrow")
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if topViewController != nil {
            return topViewController!.preferredStatusBarStyle()
        } else {
            return .Default
        }
    }
}
