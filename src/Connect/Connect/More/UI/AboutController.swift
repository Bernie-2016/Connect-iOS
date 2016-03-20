import UIKit

class AboutController: UIViewController {
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlProvider: URLProvider
    private let theme: Theme

    private let scrollView = UIScrollView.newAutoLayoutView()
    private let containerView = UIView.newAutoLayoutView()
    private var containerViewWidthConstraint: NSLayoutConstraint!

    let versionLabel = UILabel.newAutoLayoutView()
    let bodyTextLabel = UILabel.newAutoLayoutView()
    let contributeLabel = UILabel.newAutoLayoutView()
    let githubButton = UIButton.newAutoLayoutView()
    let slackButton = UIButton.newAutoLayoutView()

    init(
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlProvider: URLProvider,
        theme: Theme) {

        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlProvider = urlProvider
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        self.title = NSLocalizedString("About_title", comment: "")
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(versionLabel)
        containerView.addSubview(bodyTextLabel)
        containerView.addSubview(contributeLabel)
        containerView.addSubview(githubButton)
        containerView.addSubview(slackButton)

        let marketingVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? "unknown version"
        let internalBuildNumber  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String  ?? "unknown build"

        let versionString = "Version: \(marketingVersion) (\(internalBuildNumber))"
        versionLabel.text = versionString

        bodyTextLabel.text = NSLocalizedString("About_bodyText", comment: "")
        contributeLabel.text = NSLocalizedString("About_contributeText", comment: "")
        githubButton.setTitle(NSLocalizedString("About_githubButton", comment: ""), forState: .Normal)
        slackButton.setTitle(NSLocalizedString("About_slackButton", comment: ""), forState: .Normal)

        githubButton.addTarget(self, action: "didTapGithub", forControlEvents: .TouchUpInside)
        slackButton.addTarget(self, action: "didTapSlack", forControlEvents: .TouchUpInside)

        setupConstraintsAndLayout()
        applyTheme()
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent === nil {
            self.analyticsService.trackBackButtonTapOnScreen("About", customAttributes: nil)
        }
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        let screenBounds = UIScreen.mainScreen().bounds
        self.containerViewWidthConstraint.constant = screenBounds.width
    }


    // MARK: Actions

    func didTapGithub() {
        self.analyticsService.trackContentViewWithName("GitHub", type: .About, identifier: self.urlProvider.githubURL().absoluteString)
        self.urlOpener.openURL(self.urlProvider.githubURL())
    }

    func didTapSlack() {
        self.analyticsService.trackContentViewWithName("Slack", type: .About, identifier: self.urlProvider.slackURL().absoluteString)
        self.urlOpener.openURL(self.urlProvider.slackURL())
    }

    // MARK: Private

    private func setupConstraintsAndLayout() {
        let screenBounds = UIScreen.mainScreen().bounds

        scrollView.contentSize.width = self.view.bounds.width
        scrollView.autoPinEdgesToSuperviewEdges()

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerViewWidthConstraint = self.containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        bodyTextLabel.numberOfLines = 0
        bodyTextLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 16)
        bodyTextLabel.autoPinEdgeToSuperviewMargin(.Left)
        bodyTextLabel.autoPinEdgeToSuperviewMargin(.Right)

        contributeLabel.numberOfLines = 0
        contributeLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: bodyTextLabel, withOffset: 8)
        contributeLabel.autoPinEdgeToSuperviewMargin(.Left)
        contributeLabel.autoPinEdgeToSuperviewMargin(.Right)

        slackButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: contributeLabel, withOffset: 8)
        slackButton.autoPinEdgeToSuperviewMargin(.Left)
        slackButton.autoPinEdgeToSuperviewMargin(.Right)

        githubButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: slackButton, withOffset: 16)
        githubButton.autoPinEdgeToSuperviewMargin(.Left)
        githubButton.autoPinEdgeToSuperviewMargin(.Right)

        versionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: githubButton, withOffset: 8)
        versionLabel.autoPinEdgeToSuperviewMargin(.Left)
        versionLabel.autoPinEdgeToSuperviewMargin(.Right)
        versionLabel.autoPinEdgeToSuperviewMargin(.Bottom)
    }

    private func applyTheme() {
        view.backgroundColor = theme.contentBackgroundColor()
        versionLabel.font = theme.aboutBodyTextFont()
        bodyTextLabel.font = theme.aboutBodyTextFont()
        contributeLabel.font = theme.aboutBodyTextFont()
        githubButton.backgroundColor = theme.aboutButtonBackgroundColor()
        githubButton.titleLabel!.font = theme.aboutButtonFont()
        githubButton.setTitleColor(theme.aboutButtonTextColor(), forState: .Normal)
        slackButton.backgroundColor = theme.aboutButtonBackgroundColor()
        slackButton.titleLabel!.font = theme.aboutButtonFont()
        slackButton.setTitleColor(theme.aboutButtonTextColor(), forState: .Normal)
    }
}
