import UIKit

class ActionsController: UIViewController {
    private let urlProvider: URLProvider
    private let urlOpener: URLOpener
    private let analyticsService: AnalyticsService
    private let actionAlertService: ActionAlertService
    private let actionAlertControllerProvider: ActionAlertControllerProvider
    private let actionsTableViewCellPresenter: ActionsTableViewCellPresenter
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    private let tableView = UITableView.newAutoLayoutView()
    let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    private var actionAlerts = [ActionAlert]()

    init(urlProvider: URLProvider,
        urlOpener: URLOpener,
        actionAlertService: ActionAlertService,
        actionAlertControllerProvider: ActionAlertControllerProvider,
        actionsTableViewCellPresenter: ActionsTableViewCellPresenter,
        analyticsService: AnalyticsService,
        tabBarItemStylist: TabBarItemStylist,
        theme: Theme) {

        self.urlProvider = urlProvider
        self.urlOpener = urlOpener
        self.actionAlertService = actionAlertService
        self.actionAlertControllerProvider = actionAlertControllerProvider
        self.actionsTableViewCellPresenter = actionsTableViewCellPresenter
        self.analyticsService = analyticsService
        self.tabBarItemStylist = tabBarItemStylist
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Actions_title", comment: "")
        tabBarItemStylist.applyThemeToBarBarItem(tabBarItem,
            image: UIImage(named: "actionsTabBarIconInactive")!,
            selectedImage: UIImage(named: "actionsTabBarIcon")!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(loadingIndicatorView)

        tableView.hidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(ActionAlertTableViewCell.self, forCellReuseIdentifier: "actionAlertCell")
        tableView.registerClass(ActionTableViewCell.self, forCellReuseIdentifier: "actionCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = theme.defaultBackgroundColor()

        setupConstraints()
        loadingIndicatorView.startAnimating()
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.color = theme.defaultSpinnerColor()

    }

    override func viewWillAppear(animated: Bool) {
        actionAlertService.fetchActionAlerts().then { actionAlerts in
            self.actionAlerts = actionAlerts
            self.tableView.reloadData()
            self.loadingIndicatorView.stopAnimating()
            self.tableView.hidden = false
            }.error { _ in
                self.tableView.hidden = false
                self.loadingIndicatorView.stopAnimating()
        }
    }

    // MARK: Private

    private func setupConstraints() {
        tableView.autoPinEdgesToSuperviewEdges()

        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Horizontal)
    }
}

extension ActionsController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionAlerts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return actionsTableViewCellPresenter.presentActionAlertTableViewCell(actionAlerts[indexPath.row], tableView: tableView)
    }
}

extension ActionsController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = actionAlertControllerProvider.provideInstanceWithActionAlert(actionAlerts[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}
