import UIKit


public class NewsFeedController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let newsItemRepository: NewsItemRepository!
    let imageRepository: ImageRepository!
    let dateFormatter: NSDateFormatter!
    let newsItemControllerProvider: NewsItemControllerProvider!
    let settingsController: SettingsController!
    let analyticsService: AnalyticsService!
    let theme: Theme!
    
    public let tableView = UITableView.newAutoLayoutView()
    public let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()
    
    private var newsItems: Array<NewsItem>!
    
    public init(
        newsItemRepository: NewsItemRepository,
        imageRepository: ImageRepository,
        dateFormatter: NSDateFormatter,
        newsItemControllerProvider: NewsItemControllerProvider,
        settingsController: SettingsController,
        analyticsService: AnalyticsService,
        theme: Theme
        ) {
            self.newsItemRepository = newsItemRepository
            self.imageRepository = imageRepository
            self.dateFormatter = dateFormatter
            self.newsItemControllerProvider = newsItemControllerProvider
            self.settingsController = settingsController
            self.analyticsService = analyticsService
            self.theme = theme
            
            self.newsItems = []
            
            super.init(nibName: nil, bundle: nil)
            
            tabBarItem.setTitlePositionAdjustment(UIOffsetMake(0, -4))
            tabBarItem.image = UIImage(named: "newsTabBarIconInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "newsTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            
            let activeTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarActiveTextColor()]
            let inactiveTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarInactiveTextColor()]
            
            tabBarItem.setTitleTextAttributes(inactiveTabBarTextAttributes, forState: .Normal)
            tabBarItem.setTitleTextAttributes(activeTabBarTextAttributes, forState: .Selected)
            
            title = NSLocalizedString("NewsFeed_tabBarTitle", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let settingsIcon = UIImage(named: "settingsIcon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: settingsIcon, style: .Plain, target: self, action: "didTapSettings")

        navigationItem.title = NSLocalizedString("NewsFeed_navigationTitle", comment: "")
        
        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("NewsFeed_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)
        
        navigationItem.backBarButtonItem = backBarButtonItem

        
        view.addSubview(tableView)
        view.addSubview(loadingIndicatorView)
        
        tableView.contentInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.hidden = true
        tableView.registerClass(TitleSubTitleTableViewCell.self, forCellReuseIdentifier: "regularCell")
        tableView.registerClass(NewsHeadlineTableViewCell.self, forCellReuseIdentifier: "headlineCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.autoPinEdgesToSuperviewEdges()
        
        loadingIndicatorView.startAnimating()
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Horizontal)
        loadingIndicatorView.color = self.theme.defaultSpinnerColor()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.newsItemRepository.fetchNewsItems({ (receivedNewsItems) -> Void in
            self.tableView.hidden = false
            self.loadingIndicatorView.stopAnimating()
            self.newsItems = receivedNewsItems
            self.tableView.reloadData()
            }, error: { (error) -> Void in
                self.analyticsService.trackError(error, context: "Failed to load news feed")
                
                println(error.localizedDescription)
                // TODO: error handling.
        })
    }
    
    // MARK: UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.newsItems.count > 0 ? 2 : 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.newsItems.count == 0) {
            return 0
        }
        
        return section == 0 ? 1 : self.newsItems.count - 1
    }
    
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("headlineCell", forIndexPath: indexPath) as! NewsHeadlineTableViewCell
            let newsItem = self.newsItems[indexPath.row]
            cell.titleLabel.text = newsItem.title
            cell.titleLabel.textColor = self.theme.newsfeedHeadlineTitleColor()
            cell.titleLabel.backgroundColor = self.theme.newsFeedHeadlineTitleBackgroundColor()
            cell.titleLabel.font = self.theme.newsFeedHeadlineTitleFont()
            
            cell.headlineImageView.image = UIImage(named: "newsHeadlinePlaceholder")
            
            if(newsItem.imageURL != nil) {
                self.imageRepository.fetchImageWithURL(newsItem.imageURL!).then({ (image) -> AnyObject! in
                    UIView.transitionWithView(cell.headlineImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                        cell.headlineImageView.image = image as? UIImage
                        }, completion: nil)
                    return image
                    }, error: nil)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("regularCell", forIndexPath: indexPath) as! TitleSubTitleTableViewCell
            let newsItem = self.newsItems[indexPath.row + 1]
            cell.titleLabel.text = newsItem.title
            cell.titleLabel.font = self.theme.newsFeedTitleFont()
            cell.titleLabel.textColor = self.theme.newsFeedTitleColor()
            
            cell.dateLabel.text = self.dateFormatter.stringFromDate(newsItem.date)
            cell.dateLabel.font = self.theme.newsFeedDateFont()
            cell.dateLabel.textColor = self.theme.newsFeedDateColor()
            
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 180.0 : 90.0
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var newsItem : NewsItem!
        if(indexPath.section == 0) {
            newsItem = self.newsItems[0]
        } else {
            newsItem = self.newsItems[indexPath.row + 1]
        }
        
        self.analyticsService.trackContentViewWithName(newsItem.title, type: .NewsItem, id: newsItem.URL.absoluteString!)
        
        let controller = self.newsItemControllerProvider.provideInstanceWithNewsItem(newsItem)
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Actions
    
    func didTapSettings() {
        self.analyticsService.trackCustomEventWithName("Tapped 'Settings' in News nav bar", customAttributes: nil)
        self.navigationController?.pushViewController(self.settingsController, animated: true)
    }
}
