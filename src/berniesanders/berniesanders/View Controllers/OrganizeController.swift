import UIKit
import PureLayout

public class OrganizeController : UIViewController, UIWebViewDelegate {
    let urlProvider : URLProvider!
    let theme : Theme!
    
    public let webView = UIWebView()
    public let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()
    
    public init(urlProvider: URLProvider, theme: Theme) {
        self.urlProvider = urlProvider
        self.theme = theme
        
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem.setTitlePositionAdjustment(UIOffsetMake(0, -4))
        tabBarItem.image = UIImage(named: "organizeTabBarIconInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        tabBarItem.selectedImage = UIImage(named: "organizeTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        let activeTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarActiveTextColor()]
        let inactiveTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarInactiveTextColor()]
        
        tabBarItem.setTitleTextAttributes(inactiveTabBarTextAttributes, forState: .Normal)
        tabBarItem.setTitleTextAttributes(activeTabBarTextAttributes, forState: .Selected)

        title = NSLocalizedString("Organize_tabBarTitle", comment: "")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicatorView.color = theme.defaultSpinnerColor()
        
        webView.delegate = self
        loadingIndicatorView.stopAnimating()
        
        navigationItem.title = NSLocalizedString("Organize_navigationTitle", comment: "")
        
        setNeedsStatusBarAppearanceUpdate()
        
        var urlRequest = NSURLRequest(URL: self.urlProvider.bernieCrowdURL())
        webView.loadRequest(urlRequest)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.addSubview(self.webView)
        view.addSubview(self.loadingIndicatorView)
        
        loadingIndicatorView.autoCenterInSuperviewMargins()
        webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0))
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    // MARK: UIWebViewDelegate
    
    public func webViewDidStartLoad(webView: UIWebView) {
        self.loadingIndicatorView.startAnimating()
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        self.loadingIndicatorView.stopAnimating()
    }
}
