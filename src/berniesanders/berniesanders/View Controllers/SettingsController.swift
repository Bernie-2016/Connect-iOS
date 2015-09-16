import UIKit
import PureLayout

public class SettingsController : UIViewController {
    let theme : Theme!

    public init(theme: Theme) {
        self.theme = theme
        
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
        navigationItem.title = NSLocalizedString("Settings_navigationTitle", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        view.backgroundColor = self.theme.defaultBackgroundColor()
    }
}
