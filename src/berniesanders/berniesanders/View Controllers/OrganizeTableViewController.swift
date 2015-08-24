import UIKit

public class OrganizeTableViewController: UITableViewController {
    private let theme: Theme!
    private let organizeItemRepository: OrganizeItemRepository!
    private let dateFormatter: NSDateFormatter!
    
    private var organizeItems: Array<OrganizeItem>

    public init(
        theme: Theme,
        organizeItemRepository: OrganizeItemRepository,
        dateFormatter: NSDateFormatter
        ) {
            self.theme = theme
            self.organizeItemRepository = organizeItemRepository
            self.dateFormatter = dateFormatter
            
            self.organizeItems = []
            
            super.init(nibName: nil, bundle: nil)
            
            self.tabBarItem.image = UIImage(named: "organizeTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.title = NSLocalizedString("Organize_tabBarTitle", comment: "")
            self.navigationItem.title = NSLocalizedString("Organize_navigationTitle", comment: "")
            let attributes = [
                NSFontAttributeName: theme.tabBarFont(),
                NSForegroundColorAttributeName: theme.tabBarTextColor()
            ]
            
            self.tabBarItem.setTitleTextAttributes(attributes, forState: .Normal)
            self.tabBarItem.setTitleTextAttributes(attributes, forState: .Selected)
    }

    required public init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(TitleSubTitleTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    public override func viewWillAppear(animated: Bool) {
        self.organizeItemRepository.fetchOrganizeItems({ (receivedOrganizeItems) -> Void in
            self.organizeItems = receivedOrganizeItems
            self.tableView.reloadData()
            }, error: { (error) -> Void in
                // TODO: error handling.
        })
    }
    
    // MARK: UITableViewController
        
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.organizeItems.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TitleSubTitleTableViewCell
        let organizeItem = self.organizeItems[indexPath.row]
        cell.titleLabel.text = organizeItem.title.uppercaseString
        cell.titleLabel.font = self.theme.organizeFeedTitleFont()
        cell.titleLabel.textColor = self.theme.organizeFeedTitleColor()
        
        cell.dateLabel.text = self.dateFormatter.stringFromDate(organizeItem.date)
        cell.dateLabel.font = self.theme.organizeFeedDateFont()
        cell.dateLabel.textColor = self.theme.organizeFeedDateColor()
        
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
