import UIKit
import PureLayout


class SettingsController: UITableViewController {
    private let tappableControllers: [UIViewController]
    private let urlOpener: URLOpener
    private let urlProvider: URLProvider
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    init(tappableControllers: [UIViewController], urlOpener: URLOpener, urlProvider: URLProvider, analyticsService: AnalyticsService, tabBarItemStylist: TabBarItemStylist, theme: Theme) {
        self.tappableControllers = tappableControllers
        self.urlOpener = urlOpener
        self.urlProvider = urlProvider
        self.analyticsService = analyticsService
        self.tabBarItemStylist = tabBarItemStylist
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = NSLocalizedString("Settings_navigationTitle", comment: "")

        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Settings_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        self.tabBarItemStylist.applyThemeToBarBarItem(self.tabBarItem,
            image: UIImage(named: "moreTabBarIconInactive")!,
            selectedImage: UIImage(named: "moreTabBarIcon")!)

        title = NSLocalizedString("Settings_tabBarTitle", comment: "")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        view.backgroundColor = self.theme.defaultBackgroundColor()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "regularCell")
        self.tableView.registerClass(DonateTableViewCell.self, forCellReuseIdentifier: "donateCell")
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Settings", customAttributes: nil)
    }

    // MARK: <UITableViewDataSource>

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tappableControllers.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == self.tappableControllers.count {
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCellWithIdentifier("donateCell") as! DonateTableViewCell
            // swiftlint:enable force_cast
            cell.setupViews(self.theme)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("regularCell")!

            cell.textLabel!.text = self.tappableControllers[indexPath.row].title
            cell.textLabel!.textColor = self.theme.settingsTitleColor()
            cell.textLabel!.font = self.theme.settingsTitleFont()

            return cell
        }
    }

    // MARK: <UITableViewDelegate>

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.tappableControllers.count {
            self.urlOpener.openURL(self.urlProvider.donateFormURL())
        } else {
            let controller = self.tappableControllers[indexPath.row]
            self.analyticsService.trackContentViewWithName(controller.title!, type: .Settings, id: controller.title!)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
