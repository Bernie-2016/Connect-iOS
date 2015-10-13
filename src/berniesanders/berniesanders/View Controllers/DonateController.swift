import UIKit

class DonateController: UIViewController, UIWebViewDelegate {
    private let urlProvider: URLProvider
    private let analyticsService: AnalyticsService

    let webView = UIWebView()

    init(urlProvider: URLProvider, analyticsService: AnalyticsService) {
        self.urlProvider = urlProvider
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Settings_donate_title", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let urlRequest = NSURLRequest(URL: self.urlProvider.donateFormURL())
        self.webView.delegate = self
        self.webView.loadRequest(urlRequest)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Donate", customAttributes: nil)
    }
}
