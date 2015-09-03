import UIKit

public class OrganizeController : UIViewController {
    public init(theme: Theme) {
        super.init(nibName: nil, bundle: nil)
        
        self.tabBarItem.image = UIImage(named: "organizeTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let attributes = [
            NSFontAttributeName: theme.tabBarFont(),
            NSForegroundColorAttributeName: theme.tabBarTextColor()
        ]
        
        self.tabBarItem.setTitleTextAttributes(attributes, forState: .Normal)
        self.tabBarItem.setTitleTextAttributes(attributes, forState: .Selected)
        self.title = NSLocalizedString("Organize_tabBarTitle", comment: "")
        self.navigationItem.title = NSLocalizedString("Organize_navigationTitle", comment: "")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        var label = UILabel()
        label.text = "GET ORGANIZED!"
        
        self.view.addSubview(label)
    }
}
