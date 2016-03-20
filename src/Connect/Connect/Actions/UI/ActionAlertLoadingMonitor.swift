import UIKit

protocol ActionAlertLoadingMonitor {
    func waitUntilWebViewsHaveLoaded(webViews: [UIWebView], completionHandler: () -> ())
}

class StockActionAlertLoadingMonitor: ActionAlertLoadingMonitor {
    func waitUntilWebViewsHaveLoaded(webViews: [UIWebView], completionHandler: () -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000000000), dispatch_get_main_queue(), {
          completionHandler()
        })
    }
}
