import UIKit
import PureLayout


public class SettingsController: UITableViewController {
    private let tappableControllers: [UIViewController]
    private let analyticsService: AnalyticsService
    private let theme: Theme
    
    public init(tappableControllers: [UIViewController], analyticsService: AnalyticsService, theme: Theme) {
        self.tappableControllers = tappableControllers
        self.analyticsService = analyticsService
        self.theme = theme
        
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
        navigationItem.title = NSLocalizedString("Settings_navigationTitle", comment: "")
        
        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Settings_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)
        
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        view.backgroundColor = self.theme.defaultBackgroundColor()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "regularCell")
        self.tableView.registerClass(DonateTableViewCell.self, forCellReuseIdentifier: "donateCell")
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Settings", customAttributes: nil)
    }
    
    // MARK: <UITableViewDataSource>

    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tappableControllers.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {        
        if self.tappableControllers[indexPath.row].isKindOfClass(DonateController) {
            let cell = tableView.dequeueReusableCellWithIdentifier("donateCell") as! DonateTableViewCell
            cell.setupViews(self.theme)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("regularCell") as! UITableViewCell
            
            cell.textLabel!.text = self.tappableControllers[indexPath.row].title
            cell.textLabel!.textColor = self.theme.settingsTitleColor()
            cell.textLabel!.font = self.theme.settingsTitleFont()
            
            return cell
        }
    }
    
    // MARK: <UITableViewDelegate>
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.tappableControllers[indexPath.row]
        self.analyticsService.trackContentViewWithName(controller.title!, type: .Settings, id: controller.title!)
        self.navigationController?.pushViewController(controller, animated: true)

    }
}
