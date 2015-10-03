import UIKit
import PureLayout

public class PrivacyPolicyController : UIViewController {
    let urlProvider : URLProvider!
    let analyticsService: AnalyticsService!
    
    public let webView = UIWebView()
    
    public init(urlProvider: URLProvider, analyticsService: AnalyticsService) {
        self.urlProvider = urlProvider
        self.analyticsService = analyticsService
        
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("PrivacyPolicy_title", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var urlRequest = NSURLRequest(URL: self.urlProvider.privacyPolicyURL())
        self.webView.loadRequest(urlRequest)
        
        self.webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Privacy Policy", customAttributes: nil)
    }
}
