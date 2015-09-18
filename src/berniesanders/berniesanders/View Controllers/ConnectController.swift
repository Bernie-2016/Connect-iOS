import UIKit
import PureLayout

public class ConnectController : UIViewController {
    public let webView = UIWebView()
    let urlProvider : URLProvider!
    
    public init(urlProvider: URLProvider, theme: Theme) {
        self.urlProvider = urlProvider
        
        super.init(nibName: nil, bundle: nil)
        
        self.tabBarItem.image = UIImage(named: "connectTabBarIconInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBarItem.selectedImage = UIImage(named: "connectTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        let activeTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarActiveTextColor()]
        let inactiveTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarInactiveTextColor()]
        
        self.tabBarItem.setTitleTextAttributes(inactiveTabBarTextAttributes, forState: .Normal)
        self.tabBarItem.setTitleTextAttributes(activeTabBarTextAttributes, forState: .Selected)
        
        self.title = NSLocalizedString("Connect_tabBarTitle", comment: "")
        self.navigationItem.title = NSLocalizedString("Connect_navigationTitle", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        var urlRequest = NSURLRequest(URL: self.urlProvider.bernieEventsURL())
        self.webView.loadRequest(urlRequest)
        
        self.webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0))
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
}
