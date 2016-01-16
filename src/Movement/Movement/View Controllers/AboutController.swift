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
    let redditLabel = UILabel.newAutoLayoutView()
    let codersButton = UIButton.newAutoLayoutView()
    let designersButton = UIButton.newAutoLayoutView()
    let sandersForPresidentButton = UIButton.newAutoLayoutView()

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
        containerView.addSubview(redditLabel)
        containerView.addSubview(codersButton)
        containerView.addSubview(designersButton)
        containerView.addSubview(sandersForPresidentButton)

        let marketingVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? "unknown version"
        let internalBuildNumber  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String  ?? "unknown build"

        let versionString = "Version: \(marketingVersion) (\(internalBuildNumber))"
        versionLabel.text = versionString

        bodyTextLabel.text = NSLocalizedString("About_bodyText", comment: "")
        redditLabel.text = NSLocalizedString("About_redditText", comment: "")
        codersButton.setTitle(NSLocalizedString("About_codersForSanders", comment: ""), forState: .Normal)
        designersButton.setTitle(NSLocalizedString("About_designersForSanders", comment: ""), forState: .Normal)
        sandersForPresidentButton.setTitle(NSLocalizedString("About_sandersForPresident", comment: ""), forState: .Normal)

        codersButton.addTarget(self, action: "didTapCoders", forControlEvents: .TouchUpInside)
        designersButton.addTarget(self, action: "didTapDesigners", forControlEvents: .TouchUpInside)
        sandersForPresidentButton.addTarget(self, action: "didTapSandersForPresident", forControlEvents: .TouchUpInside)

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

    func didTapCoders() {
        self.analyticsService.trackContentViewWithName("CodersForSanders", type: .About, identifier: self.urlProvider.codersForSandersURL().absoluteString)
        self.urlOpener.openURL(self.urlProvider.codersForSandersURL())
    }

    func didTapDesigners() {
        self.analyticsService.trackContentViewWithName("DesignersForSanders", type: .About, identifier: self.urlProvider.designersForSandersURL().absoluteString)
        self.urlOpener.openURL(self.urlProvider.designersForSandersURL())
    }

    func didTapSandersForPresident() {
        self.analyticsService.trackContentViewWithName("SandersForPresident", type: .About, identifier: self.urlProvider.sandersForPresidentURL().absoluteString)
        self.urlOpener.openURL(self.urlProvider.sandersForPresidentURL())
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

        redditLabel.numberOfLines = 0
        redditLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: bodyTextLabel, withOffset: 8)
        redditLabel.autoPinEdgeToSuperviewMargin(.Left)
        redditLabel.autoPinEdgeToSuperviewMargin(.Right)

        codersButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: redditLabel, withOffset: 16)
        codersButton.autoPinEdgeToSuperviewMargin(.Left)
        codersButton.autoPinEdgeToSuperviewMargin(.Right)

        designersButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: codersButton, withOffset: 8)
        designersButton.autoPinEdgeToSuperviewMargin(.Left)
        designersButton.autoPinEdgeToSuperviewMargin(.Right)

        sandersForPresidentButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: designersButton, withOffset: 8)
        sandersForPresidentButton.autoPinEdgeToSuperviewMargin(.Left)
        sandersForPresidentButton.autoPinEdgeToSuperviewMargin(.Right)

        versionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: sandersForPresidentButton, withOffset: 8)
        versionLabel.autoPinEdgeToSuperviewMargin(.Left)
        versionLabel.autoPinEdgeToSuperviewMargin(.Right)
        versionLabel.autoPinEdgeToSuperviewMargin(.Bottom)
    }

    private func applyTheme() {
        view.backgroundColor = theme.defaultBackgroundColor()
        versionLabel.font = theme.aboutBodyTextFont()
        bodyTextLabel.font = theme.aboutBodyTextFont()
        redditLabel.font = theme.aboutBodyTextFont()
        codersButton.backgroundColor = theme.aboutButtonBackgroundColor()
        codersButton.titleLabel!.font = theme.aboutButtonFont()
        codersButton.setTitleColor(theme.aboutButtonTextColor(), forState: .Normal)
        designersButton.backgroundColor = theme.aboutButtonBackgroundColor()
        designersButton.titleLabel!.font = theme.aboutButtonFont()
        designersButton.setTitleColor(theme.aboutButtonTextColor(), forState: .Normal)
        sandersForPresidentButton.backgroundColor = theme.aboutButtonBackgroundColor()
        sandersForPresidentButton.titleLabel!.font = theme.aboutButtonFont()
        sandersForPresidentButton.setTitleColor(theme.aboutButtonTextColor(), forState: .Normal)
    }
}
