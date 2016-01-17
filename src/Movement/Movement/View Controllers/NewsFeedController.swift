import UIKit
import XCDYouTubeKit

class NewsFeedController: UIViewController {
    private let newsFeedService: NewsFeedService
    private let newsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter
    private let newsFeedItemControllerProvider: NewsFeedItemControllerProvider
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    private var errorLoadingNews = false

    let tableView = UITableView.newAutoLayoutView()
    let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    private var newsFeedItems: [NewsFeedItem]

    init(newsFeedService: NewsFeedService,
        newsFeedItemControllerProvider: NewsFeedItemControllerProvider,
        newsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter,
        analyticsService: AnalyticsService,
        tabBarItemStylist: TabBarItemStylist,
        theme: Theme ) {
            self.newsFeedService = newsFeedService
            self.newsFeedItemControllerProvider = newsFeedItemControllerProvider
            self.newsFeedTableViewCellPresenter = newsFeedTableViewCellPresenter
            self.analyticsService = analyticsService
            self.tabBarItemStylist = tabBarItemStylist
            self.theme = theme

            self.newsFeedItems = []

            super.init(nibName: nil, bundle: nil)

            self.tabBarItemStylist.applyThemeToBarBarItem(self.tabBarItem,
                image: UIImage(named: "newsTabBarIconInactive")!,
                selectedImage: UIImage(named: "newsTabBarIcon")!)

            title = NSLocalizedString("NewsFeed_tabBarTitle", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("NewsFeed_navigationTitle", comment: "")

        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("NewsFeed_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem


        view.addSubview(tableView)
        view.addSubview(loadingIndicatorView)

        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.hidden = true
        tableView.registerClass(NewsArticleTableViewCell.self, forCellReuseIdentifier: "regularCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "errorCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = self.theme.newsFeedBackgroundColor()
        tableView.autoPinEdgesToSuperviewEdges()

        newsFeedTableViewCellPresenter.setupTableView(tableView)

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

        self.newsFeedService.fetchNewsFeed({ (newsFeedItems) -> Void in
            self.errorLoadingNews = false
            self.tableView.hidden = false
            self.loadingIndicatorView.stopAnimating()
            self.newsFeedItems = newsFeedItems
            self.tableView.reloadData()
            }) { (error) -> Void in
                self.errorLoadingNews = true
                self.tableView.reloadData()
                self.analyticsService.trackError(error as NSError, context: "Failed to load news feed")
        }
    }
}

// MARK: UITableViewDataSource

extension NewsFeedController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.errorLoadingNews {
            return 1
        }

        if self.newsFeedItems.count == 0 {
            return 0
        }

        return self.newsFeedItems.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.errorLoadingNews {
            let cell = tableView.dequeueReusableCellWithIdentifier("errorCell")!
            cell.textLabel!.text = NSLocalizedString("NewsFeed_errorText", comment: "")
            cell.textLabel!.font = self.theme.newsFeedTitleFont()
            cell.textLabel!.textColor = self.theme.newsFeedTitleColor()
            return cell
        }

        let newsFeedItem = self.newsFeedItems[indexPath.row]
        return self.newsFeedTableViewCellPresenter.cellForTableView(tableView, newsFeedItem: newsFeedItem, indexPath: indexPath)
    }
}

// MARK: UITableViewDelegate

extension NewsFeedController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsFeedItem = self.newsFeedItems[indexPath.row]

        self.analyticsService.trackContentViewWithName(newsFeedItem.title, type: .NewsArticle, identifier: newsFeedItem.identifier)

        let controller = self.newsFeedItemControllerProvider.provideInstanceWithNewsFeedItem(newsFeedItem)

        self.navigationController?.pushViewController(controller, animated: true)
    }
}
