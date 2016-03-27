protocol NewVersionNotifier {
    func presentAlertIfOutOfDateOnController(controller: UIViewController)
}

class StockNewVersionNotifier: NewVersionNotifier {
    private let appVersionCompatibilityUseCase: AppVersionCompatibilityUseCase
    private let urlOpener: URLOpener
    private let workQueue: NSOperationQueue
    private let resultQueue: NSOperationQueue

    init(
        appVersionCompatibilityUseCase: AppVersionCompatibilityUseCase,
        urlOpener: URLOpener,
        workQueue: NSOperationQueue,
        resultQueue: NSOperationQueue
        ) {
        self.appVersionCompatibilityUseCase = appVersionCompatibilityUseCase
        self.urlOpener = urlOpener
        self.workQueue = workQueue
        self.resultQueue = resultQueue
    }

    func presentAlertIfOutOfDateOnController(controller: UIViewController) {
        workQueue.addOperationWithBlock {
            self.appVersionCompatibilityUseCase.checkCurrentAppVersion { updateURL in
                self.resultQueue.addOperationWithBlock {
                    let alertController = self.setupAlertController(updateURL)

                    controller.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    private func setupAlertController(updateURL: NSURL) -> UIViewController {
        let alertController = UIAlertController(
            title: NSLocalizedString("Update_alertTitle", comment: ""),
            message: NSLocalizedString("Update_alertMessage", comment: ""),
            preferredStyle: .Alert)

        let action = UIAlertAction(title: NSLocalizedString("Update_alertButtonTitle", comment: ""), style: .Default) { _ in
            self.urlOpener.openURL(updateURL)
        }

        alertController.addAction(action)

        return alertController
    }
}
