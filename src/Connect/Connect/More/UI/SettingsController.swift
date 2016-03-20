import UIKit
import PureLayout


class SettingsController: UITableViewController {
    private let tappableControllers: [UIViewController]
    private let analyticsService: AnalyticsService
    private let theme: Theme

    init(tappableControllers: [UIViewController], analyticsService: AnalyticsService, theme: Theme) {
        self.tappableControllers = tappableControllers
        self.analyticsService = analyticsService
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Settings_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        title = NSLocalizedString("Settings_navigationTitle", comment: "")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.backgroundColor = self.theme.defaultBackgroundColor()

        tableView.registerClass(SimpleTableViewCell.self, forCellReuseIdentifier: "regularCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.analyticsService.trackBackButtonTapOnScreen("Settings", customAttributes:  nil)
        }
    }

    // MARK: <UITableViewDataSource>

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tappableControllers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("regularCell") as? SimpleTableViewCell else {
            return UITableViewCell()
        }

        cell.titleLabel.text = tappableControllers[indexPath.row].title
        cell.titleLabel.textColor = theme.settingsTitleColor()
        cell.titleLabel.font = theme.settingsTitleFont()
        cell.disclosureIndicatorView.color = theme.defaultDisclosureColor()

        if indexPath.row == (tappableControllers.count - 1) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        }

        return cell
    }

    // MARK: <UITableViewDelegate>

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.tappableControllers[indexPath.row]
        self.analyticsService.trackContentViewWithName(controller.title!, type: .Settings, identifier: controller.title!)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
