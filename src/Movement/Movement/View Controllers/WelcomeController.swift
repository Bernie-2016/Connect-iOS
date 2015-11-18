import UIKit

class WelcomeController: UIViewController {
    private let analyticsService: AnalyticsService
    private let termsAndConditionsController: TermsAndConditionsController
    private let privacyPolicyController: PrivacyPolicyController
    private let applicationSettingsRepository: ApplicationSettingsRepository
    private let theme: Theme

    var onboardingWorkflow: OnboardingWorkflow!

    let billionairesImageView = UIImageView.newAutoLayoutView()
    let takeThePowerBackLabel = UILabel.newAutoLayoutView()

    let agreeToTermsNoticeTextView = UITextView.newAutoLayoutView()
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

        agreeToTermsNoticeTextView.scrollEnabled = false
        agreeToTermsNoticeTextView.textAlignment = NSTextAlignment.Center

        let fullText = NSMutableAttributedString(string: NSLocalizedString("Welcome_agreeToTermsNoticeText", comment: ""))
        let termsAndConditions = NSAttributedString(string: NSLocalizedString("Welcome_termsAndConditions", comment: ""), attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, "terms": true])

        let privacyPolicy = NSAttributedString(string: NSLocalizedString("Welcome_privacyPolicy", comment: ""), attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, "privacy": true])

        fullText.replaceCharactersInRange((fullText.string as NSString).rangeOfString("{0}"), withAttributedString: termsAndConditions)
        fullText.replaceCharactersInRange((fullText.string as NSString).rangeOfString("{1}"), withAttributedString: privacyPolicy)
        agreeToTermsNoticeTextView.attributedText = fullText

        let tapTermsNoticeRecognizer = UITapGestureRecognizer(target: self, action: "didTapAgreeToTermsLabel:")
        agreeToTermsNoticeTextView.addGestureRecognizer(tapTermsNoticeRecognizer)

        agreeToTermsButton.setTitle(NSLocalizedString("Welcome_agreeToTermsButtonTitle", comment: ""), forState: .Normal)
        agreeToTermsButton.addTarget(self, action: "didTapAgreeToTerms", forControlEvents: .TouchUpInside)

        self.view.addSubview(billionairesImageView)
        self.view.addSubview(takeThePowerBackLabel)
        self.view.addSubview(agreeToTermsNoticeTextView)
        self.view.addSubview(agreeToTermsButton)

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(true, animated: true)
    }

    // MARK: Actions

    func didTapAgreeToTermsLabel(recognizer: UIGestureRecognizer) {
        guard let textView = recognizer.view as? UITextView else { return }
        let layoutManager = textView.layoutManager
        var location = recognizer.locationInView(textView)
        location.x = location.x - textView.textContainerInset.left
        location.y = location.y - textView.textContainerInset.top

        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        if characterIndex < textView.textStorage.length {
            let termsValue = textView.textStorage.attribute("terms", atIndex: characterIndex, effectiveRange: nil)
            let privacyPolicyValue = textView.textStorage.attribute("privacy", atIndex: characterIndex, effectiveRange: nil)

            if termsValue != nil {
                didTapViewTerms()
                return
            }

            if privacyPolicyValue != nil {
                didTapViewPrivacyPolicy()
                return
            }
        }
    }

    func didTapAgreeToTerms() {
        self.analyticsService.trackCustomEventWithName("User agreed to Terms and Conditions", customAttributes: nil)
        self.applicationSettingsRepository.userAgreedToTerms { () -> Void in
            self.onboardingWorkflow.controllerDidFinishOnboarding(self)
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

        agreeToTermsNoticeTextView.font = self.theme.agreeToTermsLabelFont()
        agreeToTermsNoticeTextView.textColor = self.theme.welcomeTextColor()
        agreeToTermsNoticeTextView.backgroundColor = self.theme.welcomeBackgroundColor()

        agreeToTermsButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        agreeToTermsButton.titleLabel!.font = self.theme.defaultButtonFont()
        agreeToTermsButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
    }

    private func setupConstraints() {
        billionairesImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
        billionairesImageView.autoAlignAxisToSuperviewAxis(.Vertical)

        takeThePowerBackLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: billionairesImageView, withOffset: -25)
        takeThePowerBackLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        takeThePowerBackLabel.autoSetDimension(.Width, toSize: 244)

        agreeToTermsButton.autoPinEdge(.Bottom, toEdge: .Top, ofView: agreeToTermsNoticeTextView, withOffset: -25)
        agreeToTermsButton.autoAlignAxisToSuperviewAxis(.Vertical)
        agreeToTermsButton.autoPinEdgeToSuperviewEdge(.Left, withInset: 25)
        agreeToTermsButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 25)
        agreeToTermsButton.autoSetDimension(.Height, toSize: 54)

        agreeToTermsNoticeTextView.autoPinEdgeToSuperviewMargin(.Left)
        agreeToTermsNoticeTextView.autoPinEdgeToSuperviewMargin(.Right)
        agreeToTermsNoticeTextView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 25)

    }
}
