import UIKit

class WelcomeController: UIViewController {
    private let analyticsService: AnalyticsService
    private let termsAndConditionsController: TermsAndConditionsController
    private let privacyPolicyController: PrivacyPolicyController
    private let applicationSettingsRepository: ApplicationSettingsRepository
    private let theme: Theme

    var onboardingRouter: OnboardingRouter!

    let billionairesImageView = UIImageView.newAutoLayoutView()
    let takeThePowerBackLabel = UILabel.newAutoLayoutView()

    // TODO: remove below
    let viewTermsButton = UIButton.newAutoLayoutView()
    let viewPrivacyPolicyButton = UIButton.newAutoLayoutView()

    let agreeToTermsNoticeLabel = UILabel.newAutoLayoutView()
    let agreeToTermsButton = UIButton.newAutoLayoutView()

    init(
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.applicationSettingsRepository.updateAnalyticsPermission(true)

        billionairesImageView.contentMode = .Left
        billionairesImageView.image = UIImage(named: "billionaires")

        takeThePowerBackLabel.numberOfLines = 0
        takeThePowerBackLabel.text = NSLocalizedString("Welcome_takeThePowerBack", comment: "")
        takeThePowerBackLabel.textAlignment = .Center

        agreeToTermsNoticeLabel.numberOfLines = 0
        agreeToTermsNoticeLabel.text = NSLocalizedString("Welcome_agreeToTermsNoticeText", comment: "")
        agreeToTermsNoticeLabel.textAlignment = .Center

        agreeToTermsButton.setTitle(NSLocalizedString("Welcome_agreeToTermsButtonTitle", comment: ""), forState: .Normal)
        agreeToTermsButton.addTarget(self, action: "didTapAgreeToTerms", forControlEvents: .TouchUpInside)

        self.view.addSubview(billionairesImageView)
        self.view.addSubview(takeThePowerBackLabel)
        self.view.addSubview(agreeToTermsNoticeLabel)
        self.view.addSubview(agreeToTermsButton)

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
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
        view.backgroundColor = self.theme.welcomeBackgroundColor()
        takeThePowerBackLabel.font = self.theme.welcomeTakeThePowerBackFont()
        takeThePowerBackLabel.textColor = self.theme.welcomeTextColor()

        agreeToTermsNoticeLabel.font = self.theme.agreeToTermsLabelFont()
        agreeToTermsNoticeLabel.textColor = self.theme.welcomeTextColor()

        agreeToTermsButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        agreeToTermsButton.titleLabel!.font = self.theme.defaultButtonFont()
        agreeToTermsButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
    }

    private func setupConstraints() {
//        let screenBounds = UIScreen.mainScreen().bounds


        billionairesImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
        billionairesImageView.autoAlignAxisToSuperviewAxis(.Vertical)

        takeThePowerBackLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: billionairesImageView, withOffset: -25)
        takeThePowerBackLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        takeThePowerBackLabel.autoSetDimension(.Width, toSize: 244)

        agreeToTermsButton.autoPinEdge(.Bottom, toEdge: .Top, ofView: agreeToTermsNoticeLabel, withOffset: -25)
        agreeToTermsButton.autoAlignAxisToSuperviewAxis(.Vertical)
        agreeToTermsButton.autoSetDimension(.Width, toSize: 335)

        agreeToTermsNoticeLabel.autoPinEdgeToSuperviewMargin(.Left)
        agreeToTermsNoticeLabel.autoPinEdgeToSuperviewMargin(.Right)
        agreeToTermsNoticeLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 25)

    }
}
