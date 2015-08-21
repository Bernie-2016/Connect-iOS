import UIKit


public class NewsTableViewController: UITableViewController {
    public var newsRepository: NewsRepository!
    var newsItems: Array<NewsItem>!
    
    required public init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)

        self.newsItems = []
        self.newsRepository = ConcreteNewsRepository()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        self.tableView.registerClass(TitleSubTitleTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override public func viewWillAppear(animated: Bool) {
        self.newsRepository.fetchNews({ (receivedNewsItems) -> Void in
            self.newsItems = receivedNewsItems
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
        cell.titleLabel.text = newsItem.title
        cell.dateLabel.text = newsItem.date.description
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}
