import UIKit


public class NewsTableViewController: UITableViewController {
    public var newsRepository: NewsRepository!
    var newsItems: Array<NewsItem>
    
    required public init!(coder aDecoder: NSCoder!) {
        self.newsItems = []

        super.init(coder: aDecoder)
        self.newsRepository = ConcreteNewsRepository()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = self.newsItems[indexPath.row].title
        
        return cell
    }
}
