import UIKit

class WelcomeController: UIViewController {
    private let analyticsService: AnalyticsService
    private let privacyPolicyController: PrivacyPolicyController
    private let applicationSettingsRepository: ApplicationSettingsRepository
    private let theme: Theme

    var onboardingWorkflow: OnboardingWorkflow!

    let actionAlertImageView = UIImageView.newAutoLayoutView()
    let takeThePowerBackLabel = UILabel.newAutoLayoutView()
    let continueButton = UIButton.newAutoLayoutView()

    init(
        applicationSettingsRepository: ApplicationSettingsRepository,
        privacyPolicyController: PrivacyPolicyController,
        analyticsService: AnalyticsService,
        theme: Theme) {

        self.applicationSettingsRepository = applicationSettingsRepository
        self.privacyPolicyController = privacyPolicyController
        self.analyticsService = analyticsService
        self.theme = theme

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applicationSettingsRepository.updateAnalyticsPermission(true)

        actionAlertImageView.contentMode = .Left
        actionAlertImageView.image = UIImage(named: "actionAlertExample")

        takeThePowerBackLabel.numberOfLines = 0
        takeThePowerBackLabel.text = NSLocalizedString("Welcome_takeThePowerBack", comment: "")
        takeThePowerBackLabel.textAlignment = .Center

        view.addSubview(actionAlertImageView)
        view.addSubview(takeThePowerBackLabel)
        view.addSubview(continueButton)

        continueButton.addTarget(self, action: "didTapContinueButton", forControlEvents: .TouchUpInside)
        continueButton.setTitle(NSLocalizedString("Welcome_agreeToTermsButtonTitle", comment: ""), forState: .Normal)

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: Actions

    func didTapContinueButton() {
        self.analyticsService.trackCustomEventWithName("User tapped continue on welcome screen", customAttributes: nil)
        self.applicationSettingsRepository.userAgreedToTerms { () -> Void in
            self.onboardingWorkflow.controllerDidFinishOnboarding(self)
        }
    }

    // MARK: Private

    private func applyTheme() {
        view.backgroundColor = self.theme.welcomeBackgroundColor()
        takeThePowerBackLabel.font = self.theme.welcomeTakeThePowerBackFont()
        takeThePowerBackLabel.textColor = self.theme.welcomeTextColor()

        continueButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        continueButton.titleLabel!.font = self.theme.defaultButtonFont()
        continueButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
    }

    private func setupConstraints() {
        actionAlertImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
        actionAlertImageView.autoAlignAxisToSuperviewAxis(.Vertical)

        takeThePowerBackLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: actionAlertImageView, withOffset: -25)
        takeThePowerBackLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        takeThePowerBackLabel.autoPinEdgeToSuperviewEdge(.Left)
        takeThePowerBackLabel.autoPinEdgeToSuperviewEdge(.Right)

        continueButton.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
        continueButton.autoSetDimension(.Height, toSize: 54)
    }
}
