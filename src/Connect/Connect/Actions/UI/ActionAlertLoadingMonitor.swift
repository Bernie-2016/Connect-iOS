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
            let resultString = webView.stringByEvaluatingJavaScriptFromString("for(var iframes=document.body.getElementsByTagName('iframe'),scripts=document.body.getElementsByTagName('script'),iframeConfigured=!1,i=0;i<iframes.length;i++){var iframe=iframes[i],style=iframe.getAttribute('style');(style&&style.match('visibility')||iframe.src.match(/youtube.com\\/embed/))&&(iframeConfigured=!0)}for(var heights=[],i=0;i<iframes.length;i++)'fb_xdm_frame_https'!=iframes[i].name&&heights.push(iframes[i].scrollHeight);var maxIframeHeight=Math.max.apply(null,heights);(iframeConfigured&&scripts.length>0&&iframes.length>0&&maxIframeHeight>200)||0==scripts.length;")

            if resultString == "true" {
                webViewsLoaded += 1
            }
        }

        if webViewsLoaded == webViews.count {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500000000), dispatch_get_main_queue(), {
                completionHandler()
            })
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50000000), dispatch_get_main_queue(), {
                self.checkForLoaded(webViews, completionHandler: completionHandler)
            })
        }
    }
}
