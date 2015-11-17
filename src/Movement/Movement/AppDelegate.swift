import UIKit


class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            let appBootstrapper = AppBootstrapper()
            return appBootstrapper.bootstrap()
    }
}
