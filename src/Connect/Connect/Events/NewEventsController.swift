import UIKit
import CoreLocation

class NewEventsController: UIViewController {
    private let interstitialController: UIViewController
    private let instructionsController: UIViewController
    private let errorController: UIViewController
    private let fetchEventsUseCase: FetchEventsUseCase
    private let childControllerBuddy: ChildControllerBuddy

    let resultsView = UIView.newAutoLayoutView()

    init(
        interstitialController: UIViewController,
        instructionsController: UIViewController,
        errorController: UIViewController,
        fetchEventsUseCase: FetchEventsUseCase,
        childControllerBuddy: ChildControllerBuddy) {
            self.interstitialController = interstitialController
            self.instructionsController = instructionsController
            self.errorController = errorController
            self.fetchEventsUseCase = fetchEventsUseCase
            self.childControllerBuddy = childControllerBuddy

            super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(resultsView)

        childControllerBuddy.add(interstitialController, to: self, containIn: resultsView)
    }
}
