import UIKit

public class NewsTableViewController: UITableViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
    }
  
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel!.text = "hey";

        return cell
    }
}
