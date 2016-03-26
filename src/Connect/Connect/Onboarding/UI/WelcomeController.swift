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
    let textContainerView = UIView.newAutoLayoutView()

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
}

// MARK: UIViewController
extension WelcomeController {
    override func viewDidLoad() {
        super.viewDidLoad()

        applicationSettingsRepository.updateAnalyticsPermission(true)

        actionAlertImageView.image = UIImage(named: "actionAlertExample")

        takeThePowerBackLabel.numberOfLines = 0
        takeThePowerBackLabel.text = NSLocalizedString("Welcome_takeThePowerBack", comment: "")
        takeThePowerBackLabel.textAlignment = .Center

        continueButton.addTarget(self, action: "didTapContinueButton", forControlEvents: .TouchUpInside)
        continueButton.setTitle(NSLocalizedString("Welcome_agreeToTermsButtonTitle", comment: ""), forState: .Normal)

        view.addSubview(textContainerView)
        view.addSubview(actionAlertImageView)
        view.addSubview(continueButton)

        textContainerView.addSubview(takeThePowerBackLabel)

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

// MARK: Actions

extension WelcomeController {
    func didTapContinueButton() {
        self.analyticsService.trackCustomEventWithName("User tapped continue on welcome screen", customAttributes: nil)
        self.applicationSettingsRepository.userAgreedToTerms { () -> Void in
            self.onboardingWorkflow.controllerDidFinishOnboarding(self)
        }
    }
}

// MARK: Private

extension WelcomeController {
    private func applyTheme() {
        view.backgroundColor = self.theme.welcomeBackgroundColor()
        takeThePowerBackLabel.font = self.theme.welcomeTakeThePowerBackFont()
        takeThePowerBackLabel.textColor = self.theme.welcomeTextColor()

        continueButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        continueButton.titleLabel!.font = self.theme.defaultButtonFont()
        continueButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
    }

    // swiftlint:disable function_body_length
    private func setupConstraints() {
        let deviceType = DeviceDetective.identifyDevice()
        var actionAlertImageViewHorizontalPadding: CGFloat!
        var actionAlertImageViewBottomPadding: CGFloat!
        var textContainerViewHeight: CGFloat!

        switch deviceType {
        case .Four:
            actionAlertImageViewHorizontalPadding = 39
            actionAlertImageViewBottomPadding = 81
            textContainerViewHeight = 81
        case .Five:
            actionAlertImageViewHorizontalPadding = 40
            actionAlertImageViewBottomPadding = 139
            textContainerViewHeight = 135
        case .Six:
            actionAlertImageViewHorizontalPadding = 40
            actionAlertImageViewBottomPadding = 139
            textContainerViewHeight = 135
        case .SixPlus:
            actionAlertImageViewHorizontalPadding = 41
            actionAlertImageViewBottomPadding = 148
            textContainerViewHeight = 148
        case .NewAndShiny:
            actionAlertImageViewHorizontalPadding = 40
            actionAlertImageViewBottomPadding = 139
            textContainerViewHeight = 135
        }

        textContainerView.autoPinEdgeToSuperviewEdge(.Top)
        textContainerView.autoPinEdgeToSuperviewEdge(.Left)
        textContainerView.autoPinEdgeToSuperviewEdge(.Right)
        textContainerView.autoSetDimension(.Height, toSize: textContainerViewHeight)

        switch deviceType {
        case .Four:
            takeThePowerBackLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: textContainerView, withOffset: 4)
        default:
            takeThePowerBackLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
        }
        takeThePowerBackLabel.autoAlignAxisToSuperviewAxis(.Vertical)

        actionAlertImageView.autoPinEdge(.Top, toEdge: .Bottom, ofView: textContainerView)
        actionAlertImageView.autoPinEdgeToSuperviewEdge(.Left, withInset: actionAlertImageViewHorizontalPadding)
        actionAlertImageView.autoPinEdgeToSuperviewEdge(.Right, withInset: actionAlertImageViewHorizontalPadding)
        actionAlertImageView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: actionAlertImageViewBottomPadding)

        continueButton.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
        continueButton.autoSetDimension(.Height, toSize: 54)
    }
    // swiftlint:enable function_body_length
}
