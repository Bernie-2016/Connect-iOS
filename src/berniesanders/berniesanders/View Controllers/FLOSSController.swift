import UIKit
import PureLayout

public class FLOSSController : UIViewController {
    public let webView = UIWebView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("FLOSS_title", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let flossLicensesPath = NSBundle.mainBundle().pathForResource("floss_licenses", ofType: "html")!
        let flossLicencesURL = NSURL(fileURLWithPath: flossLicensesPath)!
        var urlRequest = NSURLRequest(URL: flossLicencesURL)
        self.webView.loadRequest(urlRequest)
        
        self.webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
