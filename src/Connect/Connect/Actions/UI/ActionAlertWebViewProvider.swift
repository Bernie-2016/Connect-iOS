import UIKit

protocol ActionAlertWebViewProvider {
    func provideInstanceWithBody(body: String, width: CGFloat) -> UIWebView
}

class StockActionAlertWebViewProvider: ActionAlertWebViewProvider {
    private let urlProvider: BaseURLProvider

    init(urlProvider: BaseURLProvider) {
        self.urlProvider = urlProvider
    }

    func provideInstanceWithBody(body: String, width: CGFloat) -> UIWebView {
        let webView = UIWebView.newAutoLayoutView()

        webView.loadHTMLString("<html><head><script src='//platform.twitter.com/widgets.js' charset='utf-8'></script><script src='https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js'></script><style type='text/css'>html { height: 100%; width: 100%; border-radius: 4px; overflow-x: hidden; } body { margin: 0px; overflow-x: hidden; font-family: -apple-system, 'Helvetica Neue', 'Lucida Grande'; } body > blockquote, .custom-body { background-color: white; border-radius: 4px; display: inline-block; width: \(width - 36)px; padding: 8px; overflow: hidden; } .fb_iframe_widget iframe { margin-top: -10px !important; overflow-x: hidden;} .fb-post iframe { margin-left: -10px; } iframe[src^='https://www.youtube.com'] { width: \(width)px !important; border-radius: 4px; overflow: hidden; }</style></head><body>\(body)</body></html>", baseURL: urlProvider.connectBaseURL())

        return webView
    }
}
