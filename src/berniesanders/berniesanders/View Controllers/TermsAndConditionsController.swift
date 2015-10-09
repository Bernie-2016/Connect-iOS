import UIKit
import PureLayout

public class TermsAndConditionsController: UIViewController {
    let analyticsService: AnalyticsService
    public let webView = UIWebView()
    
    public init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
        
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("TermsAndConditions_title", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let termsAndConditionsLicensesPath = NSBundle.mainBundle().pathForResource("terms_and_conditions", ofType: "html")!
        let termsAndConditionsLicencesURL = NSURL(fileURLWithPath: termsAndConditionsLicensesPath)!
        var urlRequest = NSURLRequest(URL: termsAndConditionsLicencesURL)
        self.webView.loadRequest(urlRequest)
        
        self.webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    public override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Terms and Conditions", customAttributes: nil)
    }
}
