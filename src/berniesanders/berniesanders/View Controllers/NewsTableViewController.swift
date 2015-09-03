import UIKit


public class NewsTableViewController: UITableViewController {
    private let theme: Theme!
    private let newsItemRepository: NewsItemRepository!
    private let dateFormatter: NSDateFormatter!
    private let newsItemControllerProvider : NewsItemControllerProvider!

    private var newsItems: Array<NewsItem>!
    
    public init(
        theme: Theme,
        newsItemRepository: NewsItemRepository,
        dateFormatter: NSDateFormatter,
        newsItemControllerProvider: NewsItemControllerProvider
        ) {
            
        self.theme = theme
        self.newsItemRepository = newsItemRepository
        self.dateFormatter = dateFormatter
        self.newsItemControllerProvider = newsItemControllerProvider
            
        self.newsItems = []
            
        super.init(nibName: nil, bundle: nil)
        
        self.tabBarItem.image = UIImage(named: "newsTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let attributes = [
            NSFontAttributeName: theme.tabBarFont(),
            NSForegroundColorAttributeName: theme.tabBarTextColor()
        ]
        
        self.tabBarItem.setTitleTextAttributes(attributes, forState: .Normal)
        self.tabBarItem.setTitleTextAttributes(attributes, forState: .Selected)
        self.title = NSLocalizedString("NewsFeed_tabBarTitle", comment: "")
        self.navigationItem.title = NSLocalizedString("NewsFeed_navigationTitle", comment: "")
    }

    public required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        self.tableView.registerClass(TitleSubTitleTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.newsItemRepository.fetchNewsItems({ (receivedNewsItems) -> Void in
            self.newsItems = receivedNewsItems
            self.tableView.reloadData()
        }, error: { (error) -> Void in
            println(error.domain)
            // TODO: error handling.
        })
    }
  
    // MARK: UITableViewController
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsItems.count
    }

    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TitleSubTitleTableViewCell
        let newsItem = self.newsItems[indexPath.row]
        cell.titleLabel.text = newsItem.title.uppercaseString
        cell.titleLabel.font = self.theme.newsFeedTitleFont()
        cell.titleLabel.textColor = self.theme.newsFeedTitleColor()

        cell.dateLabel.text = self.dateFormatter.stringFromDate(newsItem.date)
        cell.dateLabel.font = self.theme.newsFeedDateFont()
        cell.dateLabel.textColor = self.theme.newsFeedDateColor()
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var newsItem = self.newsItems[indexPath.row]
        let controller = self.newsItemControllerProvider.provideInstanceWithNewsItem(newsItem)
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
