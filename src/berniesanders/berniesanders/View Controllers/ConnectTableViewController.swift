import UIKit

public class ConnectTableViewController: UITableViewController {
    private let theme: Theme!
    private let connectItemRepository: ConnectItemRepository!
    private let dateFormatter: NSDateFormatter!
    
    private var connectItems: Array<ConnectItem>
    
    
    public init(
        theme: Theme,
        connectItemRepository: ConnectItemRepository,
        dateFormatter: NSDateFormatter        
        ) {
            self.theme = theme
            self.connectItemRepository = connectItemRepository
            self.dateFormatter = dateFormatter
            
            self.connectItems = []
            
            super.init(nibName: nil, bundle: nil)
            
            self.tabBarItem.image = UIImage(named: "connectTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            let attributes = [
                NSFontAttributeName: theme.tabBarFont(),
                NSForegroundColorAttributeName: theme.tabBarTextColor()
            ]
            
            self.tabBarItem.setTitleTextAttributes(attributes, forState: .Normal)
            self.tabBarItem.setTitleTextAttributes(attributes, forState: .Selected)
            self.title = NSLocalizedString("Connect_tabBarTitle", comment: "")
            self.navigationItem.title = NSLocalizedString("Connect_navigationTitle", comment: "")
    }
    
    required public init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.connectItemRepository.fetchConnectItems({ (receivedConnectItems) -> Void in
            self.connectItems = receivedConnectItems
            self.tableView.reloadData()
            }, error: { (error) -> Void in
                // TODO: error handling.
        })

    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(TitleSubTitleTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: UITableViewController
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.connectItems.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TitleSubTitleTableViewCell
        let connectItems = self.connectItems[indexPath.row]
        cell.titleLabel.text = connectItems.title.uppercaseString
        cell.titleLabel.font = self.theme.connectFeedTitleFont()
        cell.titleLabel.textColor = self.theme.connectFeedTitleColor()
        
        cell.dateLabel.text = self.dateFormatter.stringFromDate(connectItems.date)
        cell.dateLabel.font = self.theme.connectFeedDateFont()
        cell.dateLabel.textColor = self.theme.connectFeedDateColor()
        
        return cell
    }
    
    override public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = TableHeaderView(title: "District text goes here")
        headerCell.contentView.backgroundColor = self.theme.feedHeaderBackgroundColor()
        headerCell.titleLabel.textColor = self.theme.feedHeaderTextColor()
        headerCell.titleLabel.font = self.theme.feedHeaderFont()
        return headerCell
    }
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    public override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
}

