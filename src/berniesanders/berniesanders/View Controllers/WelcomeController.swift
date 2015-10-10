import UIKit

public class WelcomeController: UIViewController {
    private let analyticsService: AnalyticsService
    private let termsAndConditionsController: TermsAndConditionsController
    private let privacyPolicyController: PrivacyPolicyController
    private let applicationSettingsRepository: ApplicationSettingsRepository
    private let theme: Theme

    public var onboardingRouter: OnboardingRouter!

    private let scrollView = UIScrollView.newAutoLayoutView()
    private let containerView = UIView.newAutoLayoutView()
    public let bannerImageView = UIImageView.newAutoLayoutView()
    public let welcomeTextLabel = UILabel.newAutoLayoutView()
    public let viewTermsButton = UIButton.newAutoLayoutView()
    public let viewPrivacyPolicyButton = UIButton.newAutoLayoutView()
    public let agreeToTermsNoticeLabel = UILabel.newAutoLayoutView()
    public let agreeToTermsButton = UIButton.newAutoLayoutView()

    public init(
        applicationSettingsRepository: ApplicationSettingsRepository,
        termsAndConditionsController: TermsAndConditionsController,
        privacyPolicyController: PrivacyPolicyController,
        analyticsService: AnalyticsService,
        theme: Theme) {

        self.applicationSettingsRepository = applicationSettingsRepository
        self.termsAndConditionsController = termsAndConditionsController
        self.privacyPolicyController = privacyPolicyController
        self.analyticsService = analyticsService
        self.theme = theme

        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.applicationSettingsRepository.updateAnalyticsPermission(true)

        bannerImageView.contentMode = .Left
        bannerImageView.image = UIImage(named: "welcomeBanner")

        welcomeTextLabel.numberOfLines = 0
        welcomeTextLabel.text = NSLocalizedString("Welcome_welcomeText", comment: "")

        viewTermsButton.setTitle(NSLocalizedString("Welcome_viewTermsTitle", comment: ""), forState: .Normal)
        viewTermsButton.addTarget(self, action: "didTapViewTerms", forControlEvents: .TouchUpInside)

        viewPrivacyPolicyButton.setTitle(NSLocalizedString("Welcome_viewPrivacyPolicyTitle", comment: ""), forState: .Normal)
        viewPrivacyPolicyButton.addTarget(self, action: "didTapViewPrivacyPolicy", forControlEvents: .TouchUpInside)

        agreeToTermsNoticeLabel.numberOfLines = 0
        agreeToTermsNoticeLabel.text = NSLocalizedString("Welcome_agreeToTermsNoticeText", comment: "")

        agreeToTermsButton.setTitle(NSLocalizedString("Welcome_agreeToTermsButtonTitle", comment: ""), forState: .Normal)
        agreeToTermsButton.addTarget(self, action: "didTapAgreeToTerms", forControlEvents: .TouchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(bannerImageView)
        containerView.addSubview(welcomeTextLabel)
        containerView.addSubview(viewTermsButton)
        containerView.addSubview(viewPrivacyPolicyButton)
        containerView.addSubview(agreeToTermsNoticeLabel)
        containerView.addSubview(agreeToTermsButton)

        applyTheme()
        setupConstraints()
    }

    public override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(true, animated: true)
    }

    // MARK: Actions

    func didTapAgreeToTerms() {
        self.analyticsService.trackCustomEventWithName("User agreed to Terms and Conditions", customAttributes: nil)
        self.applicationSettingsRepository.userAgreedToTerms { () -> Void in
            self.onboardingRouter.controllerDidFinishOnboarding(self)
        }
    }

    func didTapViewTerms() {
        self.analyticsService.trackContentViewWithName("Terms and Conditions", type: .Onboarding, id: "Terms and Conditions")
        self.navigationController!.pushViewController(self.termsAndConditionsController, animated: true)
    }

    func didTapViewPrivacyPolicy() {
        self.analyticsService.trackContentViewWithName("Privacy Policy", type: .Onboarding, id: "Privacy Policy")
        self.navigationController!.pushViewController(self.privacyPolicyController, animated: true)
    }

    // MARK: Private

    private func applyTheme() {
        view.backgroundColor = self.theme.defaultBackgroundColor()
        welcomeTextLabel.font = self.theme.welcomeLabelFont()

        viewTermsButton.backgroundColor = self.theme.viewPolicyBackgroundColor()
        viewTermsButton.titleLabel!.font = self.theme.defaultButtonFont()
        viewTermsButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)

        viewPrivacyPolicyButton.backgroundColor = self.theme.viewPolicyBackgroundColor()
        viewPrivacyPolicyButton.titleLabel!.font = self.theme.defaultButtonFont()
        viewPrivacyPolicyButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)

        agreeToTermsNoticeLabel.font = self.theme.agreeToTermsLabelFont()

        agreeToTermsButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        agreeToTermsButton.titleLabel!.font = self.theme.defaultButtonFont()
        agreeToTermsButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
    }

    private func setupConstraints() {
        let screenBounds = UIScreen.mainScreen().bounds

        scrollView.contentSize.width = self.view.bounds.width
        scrollView.autoPinEdgeToSuperviewMargin(.Top)
        scrollView.autoPinEdgeToSuperviewEdge(.Left)
        scrollView.autoPinEdgeToSuperviewEdge(.Right)
        scrollView.autoPinEdgeToSuperviewEdge(.Bottom)

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        bannerImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 16)
        bannerImageView.autoPinEdgeToSuperviewMargin(.Left)
        bannerImageView.autoPinEdgeToSuperviewEdge(.Right)

        welcomeTextLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: bannerImageView)
        welcomeTextLabel.autoPinEdgeToSuperviewMargin(.Left)
        welcomeTextLabel.autoPinEdgeToSuperviewMargin(.Right)

        viewTermsButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: welcomeTextLabel, withOffset: 16)
        viewTermsButton.autoPinEdgeToSuperviewMargin(.Left)
        viewTermsButton.autoPinEdgeToSuperviewMargin(.Right)

        viewPrivacyPolicyButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: viewTermsButton, withOffset: 16)
        viewPrivacyPolicyButton.autoPinEdgeToSuperviewMargin(.Left)
        viewPrivacyPolicyButton.autoPinEdgeToSuperviewMargin(.Right)

        agreeToTermsNoticeLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: viewPrivacyPolicyButton, withOffset: 16)
        agreeToTermsNoticeLabel.autoPinEdgeToSuperviewMargin(.Left)
        agreeToTermsNoticeLabel.autoPinEdgeToSuperviewMargin(.Right)

        agreeToTermsButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: agreeToTermsNoticeLabel, withOffset: 16)
        agreeToTermsButton.autoPinEdgesToSuperviewMarginsExcludingEdge(.Top)
    }
}
