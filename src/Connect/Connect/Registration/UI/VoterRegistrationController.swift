import UIKit

class VoterRegistrationController: UIViewController {
    private let upcomingVoterRegistrationUseCase: UpcomingVoterRegistrationUseCase
    private let tabBarItemStylist: TabBarItemStylist
    private let urlOpener: URLOpener
    private let analyticsService: AnalyticsService
    private let theme: Theme

    let activityIndicatorView = UIActivityIndicatorView()
    let tableView = UITableView(frame: CGRect.zero, style: .Grouped)

    private var voterRegistrationInfo = [VoterRegistrationInfo]()

    init(upcomingVoterRegistrationUseCase: UpcomingVoterRegistrationUseCase, tabBarItemStylist: TabBarItemStylist, urlOpener: URLOpener, analyticsService: AnalyticsService, theme: Theme) {
        self.upcomingVoterRegistrationUseCase = upcomingVoterRegistrationUseCase
        self.tabBarItemStylist = tabBarItemStylist
        self.urlOpener = urlOpener
        self.analyticsService = analyticsService
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        tabBarItemStylist.applyThemeToBarBarItem(tabBarItem, image: UIImage(named: "registerTabBarIconInactive")!, selectedImage: UIImage(named: "registerTabBarIcon")!)
        title = NSLocalizedString("Registration_tabBarTitle", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerClass(RegistrationHeaderView.self, forHeaderFooterViewReuseIdentifier: String(RegistrationHeaderView))
        tableView.registerClass(SimpleTableViewCell.self, forCellReuseIdentifier: String(SimpleTableViewCell))
        tableView.tableFooterView = UIView()

        view.addSubview(activityIndicatorView)
        view.addSubview(tableView)

        displayResultsUI(false)

        upcomingVoterRegistrationUseCase.fetchUpcomingVoterRegistrations { voterRegistrations in
            self.voterRegistrationInfo = voterRegistrations
            self.tableView.reloadData()
            self.displayResultsUI(true)
        }

        applyTheme()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let row = tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(row, animated: false)
        }
    }
}

// MARK: private
private extension VoterRegistrationController {
    func displayResultsUI(resultsVisible: Bool) {
        activityIndicatorView.hidden = resultsVisible
        tableView.hidden = !resultsVisible
    }

    func setupConstraints() {
        activityIndicatorView.autoCenterInSuperview()
        tableView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        tableView.autoPinEdgeToSuperviewEdge(.Left)
        tableView.autoPinEdgeToSuperviewEdge(.Right)
        tableView.autoPinEdgeToSuperviewEdge(.Bottom)
    }

    func applyTheme() {
        view.backgroundColor = theme.defaultBackgroundColor()
        tableView.backgroundColor = theme.defaultBackgroundColor()
    }
}

// MARK: UITableViewDelegate
extension VoterRegistrationController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let info = voterRegistrationInfo[indexPath.row]

        analyticsService.trackContentViewWithName(info.stateName, type: .VoterRegistrationPage, identifier: info.url.absoluteString)
        urlOpener.openURL(info.url)
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(String(RegistrationHeaderView)) as? RegistrationHeaderView

        header?.contentView.backgroundColor = theme.registrationHeaderBackgroundColor()
        header?.label.textColor = theme.registrationHeaderTextColor()
        header?.label.font = theme.registrationHeaderFont()

        return header
    }
}

// MARK: UITableViewDataSource
extension VoterRegistrationController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voterRegistrationInfo.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(String(SimpleTableViewCell)) as? SimpleTableViewCell else {
            fatalError("badly configured table view!")
        }

        cell.titleLabel.text = voterRegistrationInfo[indexPath.row].stateName

        cell.disclosureIndicatorView.color = theme.defaultDisclosureColor()
        cell.titleLabel.font = theme.registrationStateFont()
        cell.titleLabel.textColor = theme.registrationStateTextColor()

        if indexPath.row == (voterRegistrationInfo.count - 1) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        }

        return cell
    }
}

// MARK: -
class RegistrationHeaderView: UITableViewHeaderFooterView {
    let label = UILabel.newAutoLayoutView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)
        label.text = NSLocalizedString("Registration_tableviewSectionHeader", comment: "")
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
    }

    required init?(coder aDecoder: NSCoder) { return nil }
}
