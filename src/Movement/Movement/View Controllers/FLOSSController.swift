import UIKit
import PureLayout

class FLOSSController: UIViewController {
    private let analyticsService: AnalyticsService
    let webView = UIWebView()

    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("FLOSS_title", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let flossLicensesPath = NSBundle.mainBundle().pathForResource("floss_licenses", ofType: "html")!
        let flossLicencesURL = NSURL(fileURLWithPath: flossLicensesPath)
        let urlRequest = NSURLRequest(URL: flossLicencesURL)
        self.webView.loadRequest(urlRequest)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.analyticsService.trackBackButtonTapOnScreen("Open Source Software", customAttributes: nil)
        }
    }
}
