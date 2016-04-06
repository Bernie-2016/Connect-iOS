import UIKit
import AMScrollingNavbar

class NewsFeedController: UIViewController {
    private let newsFeedService: NewsFeedService
    private let newsFeedCellProvider: NewsFeedCellProvider
    private let newsFeedItemControllerProvider: NewsFeedItemControllerProvider
    private let moreController: UIViewController
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
         moreController: UIViewController,
         analyticsService: AnalyticsService,
         tabBarItemStylist: TabBarItemStylist,
         mainQueue: NSOperationQueue,
         theme: Theme) {
            self.newsFeedService = newsFeedService
            self.newsFeedItemControllerProvider = newsFeedItemControllerProvider
            self.newsFeedCellProvider = newsFeedCellProvider
            self.moreController = moreController
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
            style: .Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        let infoButtonImage = UIImage(named: "infoButton")!
        let infoBarButtonItem = UIBarButtonItem(image: infoButtonImage, style: .Plain, target: self, action: #selector(NewsFeedController.didTapInfoButton))
        infoBarButtonItem.tintColor = theme.newsFeedInfoButtonTintColor()
        navigationItem.rightBarButtonItem = infoBarButtonItem

        refreshControl.addTarget(self, action:#selector(NewsFeedController.refresh), forControlEvents:.ValueChanged)
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
        let width = (screen.bounds.width - 30)/2

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let paddingSize: CGFloat = 10
            layout.itemSize = CGSize(width: width, height: 200)
            layout.sectionInset = UIEdgeInsets(top: paddingSize, left: paddingSize, bottom: paddingSize, right: paddingSize)
            layout.minimumInteritemSpacing = paddingSize
            layout.minimumLineSpacing = paddingSize
        }

        newsFeedCellProvider.setupCollectionView(collectionView)

        loadingIndicatorView.startAnimating()
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Horizontal)
        loadingIndicatorView.color = theme.defaultSpinnerColor()
        loadingIndicatorView.layer.zPosition = CGFloat(-MAXFLOAT)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(collectionView, delay: 50.0)
        }

        loadNewsFeed()
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
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

    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
        return true
    }
}

// MARK: Actions

extension NewsFeedController {
    func didTapInfoButton() {
        navigationController?.pushViewController(moreController, animated: true)
        analyticsService.trackCustomEventWithName("User tapped info button on news feed", customAttributes: nil)
    }
}
