import UIKit
import PureLayout


class SettingsController: UITableViewController {
    private let tappableControllers: [UIViewController]
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    init(tappableControllers: [UIViewController], analyticsService: AnalyticsService, tabBarItemStylist: TabBarItemStylist, theme: Theme) {
        self.tappableControllers = tappableControllers
        self.analyticsService = analyticsService
        self.tabBarItemStylist = tabBarItemStylist
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = NSLocalizedString("Settings_navigationTitle", comment: "")

        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Settings_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        tabBarItemStylist.applyThemeToBarBarItem(self.tabBarItem,
            image: UIImage(named: "moreTabBarIconInactive")!,
            selectedImage: UIImage(named: "moreTabBarIcon")!)

        title = NSLocalizedString("Settings_tabBarTitle", comment: "")
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

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "regularCell")
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
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("regularCell")
        if cell == nil { cell = UITableViewCell() }

        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.textLabel!.text = tappableControllers[indexPath.row].title
        cell.textLabel!.textColor = theme.settingsTitleColor()
        cell.textLabel!.font = theme.settingsTitleFont()
        cell.backgroundColor = theme.defaultTableCellBackgroundColor()

        if indexPath.row == (tappableControllers.count - 1) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
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
