import UIKit

class AboutController: UIViewController {
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlProvider: URLProvider
    private let theme: Theme

    private let scrollView = UIScrollView.newAutoLayoutView()
    private let containerView = UIView.newAutoLayoutView()
    private var containerViewWidthConstraint: NSLayoutConstraint!


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

        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)

        self.containerView.addSubview(self.bodyTextLabel)
        self.containerView.addSubview(self.redditLabel)
        self.containerView.addSubview(self.codersButton)
        self.containerView.addSubview(self.designersButton)
        self.containerView.addSubview(self.sandersForPresidentButton)

        self.bodyTextLabel.text = NSLocalizedString("About_bodyText", comment: "")
        self.redditLabel.text = NSLocalizedString("About_redditText", comment: "")
        self.codersButton.setTitle(NSLocalizedString("About_codersForSanders", comment: ""), forState: .Normal)
        self.designersButton.setTitle(NSLocalizedString("About_designersForSanders", comment: ""), forState: .Normal)
        self.sandersForPresidentButton.setTitle(NSLocalizedString("About_sandersForPresident", comment: ""), forState: .Normal)

        self.codersButton.addTarget(self, action: "didTapCoders", forControlEvents: .TouchUpInside)
        self.designersButton.addTarget(self, action: "didTapDesigners", forControlEvents: .TouchUpInside)
        self.sandersForPresidentButton.addTarget(self, action: "didTapSandersForPresident", forControlEvents: .TouchUpInside)

        self.setupConstraintsAndLayout()
        self.applyTheme()
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackBackButtonTapOnScreen("About", customAttributes: nil)
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

    func setupConstraintsAndLayout() {
        let screenBounds = UIScreen.mainScreen().bounds

        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()

        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        self.containerViewWidthConstraint = self.containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        self.bodyTextLabel.numberOfLines = 0
        self.bodyTextLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 16)
        self.bodyTextLabel.autoPinEdgeToSuperviewMargin(.Left)
        self.bodyTextLabel.autoPinEdgeToSuperviewMargin(.Right)

        self.redditLabel.numberOfLines = 0
        self.redditLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: bodyTextLabel, withOffset: 8)
        self.redditLabel.autoPinEdgeToSuperviewMargin(.Left)
        self.redditLabel.autoPinEdgeToSuperviewMargin(.Right)

        self.codersButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: redditLabel, withOffset: 16)
        self.codersButton.autoPinEdgeToSuperviewMargin(.Left)
        self.codersButton.autoPinEdgeToSuperviewMargin(.Right)

        self.designersButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: codersButton, withOffset: 8)
        self.designersButton.autoPinEdgeToSuperviewMargin(.Left)
        self.designersButton.autoPinEdgeToSuperviewMargin(.Right)

        self.sandersForPresidentButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: designersButton, withOffset: 8)
        self.sandersForPresidentButton.autoPinEdgeToSuperviewMargin(.Left)
        self.sandersForPresidentButton.autoPinEdgeToSuperviewMargin(.Right)
        self.sandersForPresidentButton.autoPinEdgeToSuperviewMargin(.Bottom)
    }

    func applyTheme() {
        self.view.backgroundColor = self.theme.defaultBackgroundColor()
        self.bodyTextLabel.font = self.theme.aboutBodyTextFont()
        self.redditLabel.font = self.theme.aboutBodyTextFont()
        self.codersButton.backgroundColor = self.theme.aboutButtonBackgroundColor()
        self.codersButton.titleLabel!.font = self.theme.aboutButtonFont()
        self.codersButton.setTitleColor(self.theme.aboutButtonTextColor(), forState: .Normal)
        self.designersButton.backgroundColor = self.theme.aboutButtonBackgroundColor()
        self.designersButton.titleLabel!.font = self.theme.aboutButtonFont()
        self.designersButton.setTitleColor(self.theme.aboutButtonTextColor(), forState: .Normal)
        self.sandersForPresidentButton.backgroundColor = self.theme.aboutButtonBackgroundColor()
        self.sandersForPresidentButton.titleLabel!.font = self.theme.aboutButtonFont()
        self.sandersForPresidentButton.setTitleColor(self.theme.aboutButtonTextColor(), forState: .Normal)
    }
}
