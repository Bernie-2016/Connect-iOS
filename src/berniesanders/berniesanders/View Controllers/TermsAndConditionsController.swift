import UIKit
import PureLayout

class TermsAndConditionsController: UIViewController {
    private let analyticsService: AnalyticsService
    let webView = UIWebView()

    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("TermsAndConditions_title", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let termsAndConditionsLicensesPath = NSBundle.mainBundle().pathForResource("terms_and_conditions", ofType: "html")!
        let termsAndConditionsLicencesURL = NSURL(fileURLWithPath: termsAndConditionsLicensesPath)
        let urlRequest = NSURLRequest(URL: termsAndConditionsLicencesURL)
        self.webView.loadRequest(urlRequest)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Terms and Conditions", customAttributes: nil)
    }
}
