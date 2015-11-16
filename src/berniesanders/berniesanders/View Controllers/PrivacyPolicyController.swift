import UIKit
import PureLayout

class PrivacyPolicyController: UIViewController {
    private let urlProvider: URLProvider
    private let analyticsService: AnalyticsService

    let webView = UIWebView()

    init(urlProvider: URLProvider, analyticsService: AnalyticsService) {
        self.urlProvider = urlProvider
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("PrivacyPolicy_title", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let urlRequest = NSURLRequest(URL: self.urlProvider.privacyPolicyURL())
        self.webView.loadRequest(urlRequest)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackBackButtonTapOnScreen("Privacy Policy", customAttributes:  nil)
    }
}
