import UIKit

protocol ActionAlertLoadingMonitor {
    func waitUntilWebViewsHaveLoaded(webViews: [UIWebView], completionHandler: () -> ())
}

class StockActionAlertLoadingMonitor: ActionAlertLoadingMonitor {
    func waitUntilWebViewsHaveLoaded(webViews: [UIWebView], completionHandler: () -> ()) {
        checkForLoaded(webViews, completionHandler: completionHandler)
    }

    private func checkForLoaded(webViews: [UIWebView], completionHandler: () -> ()) {
        var webViewsLoaded = 0
        for webView in webViews {
            let resultString = webView.stringByEvaluatingJavaScriptFromString("var iframes = document.body.getElementsByTagName('iframe') ; var scripts = document.body.getElementsByTagName('script') ; var heights = [] ; for(var i = 0; i < iframes.length ; i++) { if(iframes[i].name == 'fb_xdm_frame_https') { continue; } heights.push(iframes[i].scrollHeight); } var maxIframeHeight = Math.max.apply(null, heights); (scripts.length > 0 && iframes.length > 0 && maxIframeHeight > 200) || scripts.length == 0;")

            if resultString == "true" {
                webViewsLoaded += 1
            }
        }

        if webViewsLoaded == webViews.count {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000000000), dispatch_get_main_queue(), {
                completionHandler()
            })
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100000000), dispatch_get_main_queue(), {
                self.checkForLoaded(webViews, completionHandler: completionHandler)
            })
        }
    }
}
