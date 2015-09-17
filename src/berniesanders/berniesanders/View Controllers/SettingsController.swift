import UIKit
import PureLayout


public class SettingsController : UITableViewController {
    let privacyPolicyController : PrivacyPolicyController!
    let theme : Theme!
    
    public init(privacyPolicyController: PrivacyPolicyController, theme: Theme) {
        self.privacyPolicyController = privacyPolicyController
        self.theme = theme
        
        super.init(nibName: nil, bundle: nil)
        

        hidesBottomBarWhenPushed = true
        navigationItem.title = NSLocalizedString("Settings_navigationTitle", comment: "")
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
        return 1
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("regularCell") as! UITableViewCell
        cell.textLabel!.text = NSLocalizedString("Settings_privacyPolicy", comment: "")
        cell.textLabel!.textColor = self.theme.settingsTitleColor()
        cell.textLabel!.font = self.theme.settingsTitleFont()
        
        return cell
    }
    
    // MARK: <UITableViewDelegate>
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.pushViewController(self.privacyPolicyController, animated: true)
    }
}
