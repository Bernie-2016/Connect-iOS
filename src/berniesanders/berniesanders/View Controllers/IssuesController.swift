import UIKit

public class IssuesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let issueRepository: IssueRepository
    private let issueControllerProvider: IssueControllerProvider
    private let settingsController: SettingsController
    private let analyticsService: AnalyticsService
    private let theme: Theme

    public let tableView = UITableView.newAutoLayoutView()
    public let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    var issues: Array<Issue>!

    public init(issueRepository: IssueRepository,
        issueControllerProvider: IssueControllerProvider,
        settingsController: SettingsController,
        analyticsService: AnalyticsService!,
        theme: Theme) {
        self.issueRepository = issueRepository
        self.issueControllerProvider = issueControllerProvider
        self.settingsController = settingsController
        self.analyticsService = analyticsService
        self.theme = theme

        self.issues = []

        super.init(nibName: nil, bundle: nil)

        tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -4)
        tabBarItem.image = UIImage(named: "issuesTabBarIconInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        tabBarItem.selectedImage = UIImage(named: "issuesTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)

        let activeTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarActiveTextColor()]
        let inactiveTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarInactiveTextColor()]

        tabBarItem.setTitleTextAttributes(inactiveTabBarTextAttributes, forState: .Normal)
        tabBarItem.setTitleTextAttributes(activeTabBarTextAttributes, forState: .Selected)
        title = NSLocalizedString("Issues_tabBarTitle", comment: "")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        let settingsIcon = UIImage(named: "settingsIcon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: settingsIcon, style: .Plain, target: self, action: "didTapSettings")

        navigationItem.title = NSLocalizedString("Issues_navigationTitle", comment: "")

        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Issues_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        view.addSubview(tableView)
        view.addSubview(loadingIndicatorView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(IssueTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.hidden = true

        loadingIndicatorView.startAnimating()
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Horizontal)
        loadingIndicatorView.color = self.theme.defaultSpinnerColor()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.issueRepository.fetchIssues({ (receivedIssues) -> Void in
            self.issues = receivedIssues
            self.loadingIndicatorView.stopAnimating()
            self.tableView.hidden = false
            self.tableView.reloadData()
            }, error: { (error) -> Void in
                self.analyticsService.trackError(error, context: "Failed to load issues")

                print(error.localizedDescription)

                // TODO: error handling.
        })
    }

    // MARK: UITableViewDataSource

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.issues.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! IssueTableViewCell
        let issue = self.issues[indexPath.row]
        cell.titleLabel.text = issue.title
        cell.titleLabel.font = self.theme.issuesFeedTitleFont()
        cell.titleLabel.textColor = self.theme.issuesFeedTitleColor()

        return cell
    }

    // MARK: UITableViewDelegate

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let issue = self.issues[indexPath.row]

        self.analyticsService.trackContentViewWithName(issue.title, type: .Issue, id: issue.URL.absoluteString)

        let controller = self.issueControllerProvider.provideInstanceWithIssue(issue)
        self.navigationController!.pushViewController(controller, animated: true)
    }

    // MARK: Actions

    func didTapSettings() {
        self.analyticsService.trackCustomEventWithName("Tapped 'Settings' in Issues nav bar", customAttributes: nil)
        self.navigationController?.pushViewController(self.settingsController, animated: true)
    }
}
