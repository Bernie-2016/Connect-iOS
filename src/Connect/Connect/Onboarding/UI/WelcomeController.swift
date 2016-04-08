import UIKit

class WelcomeController: UIViewController {
    private let analyticsService: AnalyticsService
    private let privacyPolicyController: PrivacyPolicyController
    private let applicationSettingsRepository: ApplicationSettingsRepository
    private let theme: Theme

    var onboardingWorkflow: OnboardingWorkflow!

    let backgroundImageView = UIImageView.newAutoLayoutView()
    let welcomeHeaderLabel = UILabel.newAutoLayoutView()
    let welcomeMessageLabel = UILabel.newAutoLayoutView()
    let continueButton = UIButton.newAutoLayoutView()
    let scrollView = UIScrollView.newAutoLayoutView()
    private let containerView = UIView.newAutoLayoutView()

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

        backgroundImageView.image = UIImage(named: "gradientBackground")!

        welcomeHeaderLabel.numberOfLines = 1
        welcomeHeaderLabel.text = NSLocalizedString("Welcome_header", comment: "")
        welcomeHeaderLabel.textAlignment = .Left

        welcomeMessageLabel.text = NSLocalizedString("Welcome_message", comment: "")
        welcomeMessageLabel.numberOfLines = 0
        welcomeMessageLabel.textAlignment = .Left

        continueButton.addTarget(self, action: #selector(WelcomeController.didTapContinueButton), forControlEvents: .TouchUpInside)
        continueButton.setTitle(NSLocalizedString("Welcome_agreeToTermsButtonTitle", comment: ""), forState: .Normal)

        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        view.addSubview(continueButton)

        scrollView.addSubview(containerView)
        containerView.addSubview(welcomeHeaderLabel)
        containerView.addSubview(welcomeMessageLabel)

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
        view.backgroundColor = theme.welcomeBackgroundColor()
        welcomeHeaderLabel.font = theme.welcomeHeaderFont()
        welcomeHeaderLabel.textColor = theme.welcomeTextColor()
        welcomeMessageLabel.font = theme.welcomeMessageFont()
        welcomeMessageLabel.textColor = theme.welcomeTextColor()

        continueButton.backgroundColor = theme.welcomeButtonBackgroundColor()
        continueButton.titleLabel!.font = theme.defaultButtonFont()
        continueButton.setTitleColor(theme.welcomeButtonTextColor(), forState: .Normal)
    }

    // swiftlint:disable function_body_length
    private func setupConstraints() {
        let deviceType = DeviceDetective.identifyDevice()

        if deviceType < .Six {
            setupSmallDeviceConstraints()
        } else {
            setupLargeDeviceConstraints()
        }

        let screenBounds = UIScreen.mainScreen().bounds

        backgroundImageView.autoPinEdgesToSuperviewEdges()

        scrollView.contentSize.width = view.bounds.width
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        scrollView.autoPinEdgesToSuperviewEdges()

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Right)
        containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        welcomeMessageLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: welcomeHeaderLabel, withOffset: 20)

        continueButton.autoSetDimension(.Height, toSize: 50)
    }

    private func setupSmallDeviceConstraints() {
        let horizontalInset: CGFloat = 25
        welcomeHeaderLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 55)
        welcomeHeaderLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: horizontalInset)
        welcomeHeaderLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: horizontalInset)

        welcomeMessageLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: horizontalInset)
        welcomeMessageLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: horizontalInset)
        welcomeMessageLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 50)

        continueButton.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
    }

    private func setupLargeDeviceConstraints() {
        welcomeHeaderLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 65)
        welcomeHeaderLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 30)
        welcomeHeaderLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 35)

        welcomeMessageLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 30)
        welcomeMessageLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 35)
        welcomeMessageLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 50)

        continueButton.layer.cornerRadius = 4
        continueButton.autoPinEdgeToSuperviewEdge(.Left, withInset: 30)
        continueButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 30)
        continueButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 55)
    }
    // swiftlint:enable function_body_length
}
