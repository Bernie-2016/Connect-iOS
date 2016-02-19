import UIKit

class InterstitialController: UIViewController {
    private let activityIndicatorView = UIActivityIndicatorView.newAutoLayoutView()
    private let theme: Theme

    init(theme: Theme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        navigationItem.hidesBackButton = true

        view.addSubview(activityIndicatorView)

        activityIndicatorView.color = theme.defaultSpinnerColor()
        activityIndicatorView.startAnimating()

        activityIndicatorView.autoCenterInSuperview()
    }
}
