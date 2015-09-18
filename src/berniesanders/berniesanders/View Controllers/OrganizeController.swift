import UIKit
import PureLayout

public class OrganizeController : UIViewController {
    public let webView = UIWebView()
    let urlProvider : URLProvider!
    
    public init(urlProvider: URLProvider, theme: Theme) {
        self.urlProvider = urlProvider
        
        super.init(nibName: nil, bundle: nil)
        
        self.tabBarItem.image = UIImage(named: "organizeTabBarIconInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBarItem.selectedImage = UIImage(named: "organizeTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
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
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        var urlRequest = NSURLRequest(URL: self.urlProvider.bernieCrowdURL())
        self.webView.loadRequest(urlRequest)
        
        self.webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0))
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
}
