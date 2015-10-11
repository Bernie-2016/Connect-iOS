import UIKit
import PureLayout

public class FLOSSController: UIViewController {
    private let analyticsService: AnalyticsService
    public let webView = UIWebView()

    public init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("FLOSS_title", comment: "")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        let flossLicensesPath = NSBundle.mainBundle().pathForResource("floss_licenses", ofType: "html")!
        let flossLicencesURL = NSURL(fileURLWithPath: flossLicensesPath)
        let urlRequest = NSURLRequest(URL: flossLicencesURL)
        self.webView.loadRequest(urlRequest)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }

    public override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Open Source Software", customAttributes: nil)
    }
}
