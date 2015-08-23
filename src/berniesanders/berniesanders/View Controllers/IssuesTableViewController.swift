import UIKit

public class IssuesTableViewController: UITableViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Issues_tabBarTitle", comment: "")
        self.navigationItem.title = NSLocalizedString("Issues_navigationTitle", comment: "")
    }

    required public init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
