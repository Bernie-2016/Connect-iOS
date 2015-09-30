import UIKit
import PureLayout

public class PrivacyPolicyController : UIViewController {
    public let webView = UIWebView()
    let urlProvider : URLProvider!
    
    public init(urlProvider: URLProvider) {
        self.urlProvider = urlProvider
        
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("PrivacyPolicy_title", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var urlRequest = NSURLRequest(URL: self.urlProvider.privacyPolicyURL())
        self.webView.loadRequest(urlRequest)
        
        self.webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
