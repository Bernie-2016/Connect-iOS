import UIKit

class EventRSVPController: UIViewController, UIWebViewDelegate {
    let event: Event
    let analyticsService: AnalyticsService
    let theme: Theme

    let webView = UIWebView()
    let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    init(event: Event, analyticsService: AnalyticsService, theme: Theme) {
        self.event = event
        self.analyticsService = analyticsService
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.theme.defaultBackgroundColor()

        navigationItem.title = NSLocalizedString("EventRSVP_navigationTitle", comment: "")

        loadingIndicatorView.color = theme.defaultSpinnerColor()

        webView.delegate = self
        loadingIndicatorView.stopAnimating()

        let anchoredURL = NSURL(string: "#rsvp_container", relativeToURL: self.event.url)
        let urlRequest = NSURLRequest(URL: anchoredURL!)
        webView.loadRequest(urlRequest)

        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(self.webView)
        view.addSubview(self.loadingIndicatorView)

        loadingIndicatorView.autoCenterInSuperviewMargins()
        webView.autoPinEdgesToSuperviewEdges()
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            let d = [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString]
            self.analyticsService.trackBackButtonTapOnScreen("Event RSVP", customAttributes: d)
        }
    }

    // MARK: UIWebViewDelegate

    func webViewDidStartLoad(webView: UIWebView) {
        self.loadingIndicatorView.startAnimating()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        self.loadingIndicatorView.stopAnimating()
    }
}
