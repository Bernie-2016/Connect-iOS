import UIKit

public class EventRSVPController: UIViewController, UIWebViewDelegate {
    public let event: Event
    public let analyticsService: AnalyticsService
    public let theme: Theme
    
    public let webView = UIWebView()
    public let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()
    
    public init(event: Event, analyticsService: AnalyticsService, theme: Theme) {
        self.event = event
        self.analyticsService = analyticsService
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = self.theme.defaultBackgroundColor()
        
        navigationItem.title = NSLocalizedString("EventRSVP_navigationTitle", comment: "")
        
        loadingIndicatorView.color = theme.defaultSpinnerColor()
        
        webView.delegate = self
        loadingIndicatorView.stopAnimating()
        
        var anchoredURL = NSURL(string: "#rsvp_container", relativeToURL: self.event.URL)
        var urlRequest = NSURLRequest(URL: anchoredURL!)
        webView.loadRequest(urlRequest)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.addSubview(self.webView)
        view.addSubview(self.loadingIndicatorView)
        
        loadingIndicatorView.autoCenterInSuperviewMargins()
        webView.autoPinEdgesToSuperviewEdges()
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?) {
        let d = [AnalyticsServiceConstants.contentIDKey: self.event.URL.absoluteString!]
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Event RSVP", customAttributes: d)
    }
    
    // MARK: UIWebViewDelegate
    
    public func webViewDidStartLoad(webView: UIWebView) {
        self.loadingIndicatorView.startAnimating()
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        self.loadingIndicatorView.stopAnimating()
    }
}
