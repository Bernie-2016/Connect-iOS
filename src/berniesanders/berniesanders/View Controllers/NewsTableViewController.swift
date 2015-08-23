import UIKit


public class NewsTableViewController: UITableViewController {
    public var newsRepository: NewsRepository!
    public var theme: Theme!
    var newsItems: Array<NewsItem>!
    
    public init(theme: Theme, newsRepository: NewsRepository) {
        self.theme = theme
        self.newsRepository = newsRepository
        self.newsItems = []
        super.init(nibName: nil, bundle: nil)
        
        self.title = NSLocalizedString("NewsFeed_tabBarTitle", comment: "")
        self.navigationItem.title = NSLocalizedString("NewsFeed_navigationTitle", comment: "")
    }
    
    public required init!(coder aDecoder: NSCoder!) {
        self.newsItems = []
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        self.tableView.registerClass(TitleSubTitleTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.newsRepository.fetchNews({ (receivedNewsItems) -> Void in
            self.newsItems = receivedNewsItems
            self.tableView.reloadData()
        }, error: { (error) -> Void in
            // TODO: error handling.
        })
    }
  
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

        cell.dateLabel.text = newsItem.date.description
        cell.dateLabel.font = self.theme.newsFeedDateFont()
        cell.dateLabel.textColor = self.theme.newsFeedDateColor()
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}
