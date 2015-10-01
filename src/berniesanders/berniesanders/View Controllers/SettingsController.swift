import UIKit
import PureLayout


public class SettingsController : UITableViewController {
    let tappableControllers : [UIViewController]!
    let theme : Theme!
    
    public init(tappableControllers: [UIViewController], theme: Theme) {
        self.tappableControllers = tappableControllers
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
        view.backgroundColor = self.theme.defaultBackgroundColor()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "regularCell")
    }
    
    // MARK: <UITableViewDataSource>
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tappableControllers.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("regularCell") as! UITableViewCell
        cell.textLabel!.text = self.tappableControllers[indexPath.row].title
        cell.textLabel!.textColor = self.theme.settingsTitleColor()
        cell.textLabel!.font = self.theme.settingsTitleFont()
        
        return cell
    }
    
    // MARK: <UITableViewDelegate>
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.pushViewController(self.tappableControllers[indexPath.row], animated: true)
    }
}
