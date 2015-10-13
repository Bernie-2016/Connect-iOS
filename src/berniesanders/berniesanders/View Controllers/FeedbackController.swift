import UIKit

class FeedbackController: UIViewController, UIWebViewDelegate {
    private let urlProvider : URLProvider
    private let analyticsService: AnalyticsService

    let webView = UIWebView()

    init(urlProvider: URLProvider, analyticsService: AnalyticsService) {
        self.urlProvider = urlProvider
        self.analyticsService = analyticsService

        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Feedback_title", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let urlRequest = NSURLRequest(URL: self.urlProvider.feedbackFormURL())
        self.webView.delegate = self
        self.webView.loadRequest(urlRequest)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Feedback", customAttributes: nil)

    }

    // MARK: UIWebViewDelegate

    func webViewDidFinishLoad(webView: UIWebView) {
        let overrideCssPath = NSBundle.mainBundle().pathForResource("feedbackGoogleFormOverrides", ofType: "css")!
        let overrideCss = try! String(contentsOfFile: overrideCssPath, encoding: NSUTF8StringEncoding)
        let injectionJSPath = NSBundle.mainBundle().pathForResource("cssInjection", ofType: "js")!
        let injectionJS = try! String(contentsOfFile: injectionJSPath, encoding: NSUTF8StringEncoding)

        let cssInjection = injectionJS.stringByReplacingOccurrencesOfString("CSS_SENTINEL", withString:overrideCss)
        print(webView.stringByEvaluatingJavaScriptFromString(cssInjection), terminator: "")
    }
}
