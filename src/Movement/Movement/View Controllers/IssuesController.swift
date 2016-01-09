import UIKit

class IssuesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let issueService: IssueService
    private let issueControllerProvider: IssueControllerProvider
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    var errorLoadingIssues = false

    let tableView = UITableView.newAutoLayoutView()
    let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    var issues: Array<Issue>!

    init(issueService: IssueService,
        issueControllerProvider: IssueControllerProvider,
        analyticsService: AnalyticsService!,
        tabBarItemStylist: TabBarItemStylist,
        theme: Theme) {
        self.issueService = issueService
        self.issueControllerProvider = issueControllerProvider
        self.analyticsService = analyticsService
        self.tabBarItemStylist = tabBarItemStylist
        self.theme = theme

        self.issues = []

        super.init(nibName: nil, bundle: nil)

            self.tabBarItemStylist.applyThemeToBarBarItem(self.tabBarItem,
                image: UIImage(named: "issuesTabBarIconInactive")!,
                selectedImage: UIImage(named: "issuesTabBarIcon")!)

        title = NSLocalizedString("Issues_tabBarTitle", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "errorCell")
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.hidden = true

        loadingIndicatorView.startAnimating()
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Horizontal)
        loadingIndicatorView.color = self.theme.defaultSpinnerColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: false)
        }


        let issuesFuture = issueService.fetchIssues()
        issuesFuture.then { issues in
            self.errorLoadingIssues = false
            self.issues = issues
            self.loadingIndicatorView.stopAnimating()
            self.tableView.hidden = false
            self.tableView.reloadData()
        }

        issuesFuture.error { error in
            self.errorLoadingIssues = true
            self.tableView.reloadData()
            self.analyticsService.trackError(error, context: "Failed to load issues")

            print(error.localizedDescription)

        }
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.errorLoadingIssues ? 1 : self.issues.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.errorLoadingIssues {
            let cell = tableView.dequeueReusableCellWithIdentifier("errorCell", forIndexPath: indexPath)
            cell.textLabel!.text = NSLocalizedString("Issues_errorText", comment: "")
            cell.textLabel!.font = self.theme.issuesFeedTitleFont()
            cell.textLabel!.textColor = self.theme.issuesFeedTitleColor()
            return cell

        } else {
            var cell: IssueTableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell") as? IssueTableViewCell
            if cell == nil { cell = IssueTableViewCell() }

            let issue = self.issues[indexPath.row]
            cell.titleLabel.text = issue.title
            cell.titleLabel.font = self.theme.issuesFeedTitleFont()
            cell.titleLabel.textColor = self.theme.issuesFeedTitleColor()

            return cell
        }
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let issue = self.issues[indexPath.row]

        self.analyticsService.trackContentViewWithName(issue.title, type: .Issue, identifier: issue.url.absoluteString)

        let controller = self.issueControllerProvider.provideInstanceWithIssue(issue)
        self.navigationController!.pushViewController(controller, animated: true)
    }
}
