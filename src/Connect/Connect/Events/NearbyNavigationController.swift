import UIKit

class NearbyNavigationController: UINavigationController {
    let interstitialController: UIViewController

    init(interstitialController: UIViewController) {
        self.interstitialController = interstitialController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        pushViewController(interstitialController, animated: false)
    }
}
