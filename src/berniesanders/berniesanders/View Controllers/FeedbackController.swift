import UIKit

public class FeedbackController: UIViewController, UIWebViewDelegate {
    private let urlProvider : URLProvider
    private let analyticsService: AnalyticsService
    
    public let webView = UIWebView()
    
    public init(urlProvider: URLProvider, analyticsService: AnalyticsService) {
        self.urlProvider = urlProvider
        self.analyticsService = analyticsService
        
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Feedback_title", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var urlRequest = NSURLRequest(URL: self.urlProvider.feedbackFormURL())
        self.webView.delegate = self
        self.webView.loadRequest(urlRequest)
        
        self.webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.webView)
        self.webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Feedback", customAttributes: nil)

    }

    // MARK: UIWebViewDelegate
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        let overrideCssPath = NSBundle.mainBundle().pathForResource("feedbackGoogleFormOverrides", ofType: "css")!
        let overrideCss = String(contentsOfFile: overrideCssPath, encoding: NSUTF8StringEncoding, error: nil)!
        let injectionJSPath = NSBundle.mainBundle().pathForResource("cssInjection", ofType: "js")!
        let injectionJS = String(contentsOfFile: injectionJSPath, encoding: NSUTF8StringEncoding, error: nil)!
        
        let cssInjection = injectionJS.stringByReplacingOccurrencesOfString("CSS_SENTINEL", withString:overrideCss)
        print(webView.stringByEvaluatingJavaScriptFromString(cssInjection))
    }
}
