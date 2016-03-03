import UIKit

class NewsFeedController: UIViewController {
    private let newsFeedService: NewsFeedService
    private let newsFeedCellProvider: NewsFeedCellProvider
    private let newsFeedItemControllerProvider: NewsFeedItemControllerProvider
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let mainQueue: NSOperationQueue
    private var theme: Theme

    private var errorLoadingNews = false

    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    let refreshControl = UIRefreshControl()
    let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    private var newsFeedItems: [NewsFeedItem]

    init(newsFeedService: NewsFeedService,
         newsFeedItemControllerProvider: NewsFeedItemControllerProvider,
         newsFeedCellProvider: NewsFeedCellProvider,
         analyticsService: AnalyticsService,
         tabBarItemStylist: TabBarItemStylist,
         mainQueue: NSOperationQueue,
         theme: Theme) {
            self.newsFeedService = newsFeedService
            self.newsFeedItemControllerProvider = newsFeedItemControllerProvider
            self.newsFeedCellProvider = newsFeedCellProvider
            self.analyticsService = analyticsService
            self.tabBarItemStylist = tabBarItemStylist
            self.mainQueue = mainQueue
            self.theme = theme

            self.newsFeedItems = []

            super.init(nibName: nil, bundle: nil)

            tabBarItemStylist.applyThemeToBarBarItem(tabBarItem,
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

        refreshControl.addTarget(self, action:"refresh", forControlEvents:.ValueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.sendSubviewToBack(refreshControl)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicatorView)

        collectionView.hidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = theme.newsFeedBackgroundColor()
        collectionView.autoPinEdgesToSuperviewEdges()

        let screen = UIScreen.mainScreen()
        let width = (screen.bounds.width - 45)/2

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: width, height: 200)
            layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15)
            layout.minimumInteritemSpacing = 15.0
            layout.minimumLineSpacing = 15.0
        }

        newsFeedCellProvider.setupCollectionView(collectionView)

        loadingIndicatorView.startAnimating()
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Horizontal)
        loadingIndicatorView.color = theme.defaultSpinnerColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

//        if let selectedRowIndexPath = collectionView.indexPathForSelectedRow {
//            tableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: false)
//        }

        loadNewsFeed()
    }

    func loadNewsFeed() {
        newsFeedService.fetchNewsFeed().then { newsFeedItems in
            self.mainQueue.addOperationWithBlock { self.refreshControl.endRefreshing() }
            self.errorLoadingNews = false
            self.collectionView.hidden = false
            self.loadingIndicatorView.stopAnimating()
            self.newsFeedItems = newsFeedItems
            self.collectionView.reloadData()
        }.error { error in
            self.mainQueue.addOperationWithBlock { self.refreshControl.endRefreshing() }
            self.errorLoadingNews = true
            self.collectionView.reloadData()
            self.analyticsService.trackError(error, context: "Failed to load news feed")
        }
    }

    func refresh() {
        refreshControl.beginRefreshing()
        loadNewsFeed()
    }
}


// MARK: UICollectionViewDataSource

extension NewsFeedController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsFeedItems.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let newsFeedItem = newsFeedItems[indexPath.row]
        return newsFeedCellProvider.cellForCollectionView(collectionView, newsFeedItem: newsFeedItem, indexPath: indexPath)!
    }
}


// MARK: UICollectionViewDelegate

extension NewsFeedController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let newsFeedItem = newsFeedItems[indexPath.row]

        analyticsService.trackContentViewWithName(newsFeedItem.title, type: .NewsArticle, identifier: newsFeedItem.identifier)

        let controller = newsFeedItemControllerProvider.provideInstanceWithNewsFeedItem(newsFeedItem)
        navigationController?.pushViewController(controller, animated: true)
    }
}
