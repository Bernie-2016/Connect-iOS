import UIKit

class VoterRegistrationController: UIViewController {
    private let upcomingVoterRegistrationUseCase: UpcomingVoterRegistrationUseCase
    private let tabBarItemStylist: TabBarItemStylist
    private let urlOpener: URLOpener

    let activityIndicatorView = UIActivityIndicatorView()
    let tableView = UITableView()

    private var voterRegistrationInfo = [VoterRegistrationInfo]()

    init(upcomingVoterRegistrationUseCase: UpcomingVoterRegistrationUseCase, tabBarItemStylist: TabBarItemStylist, urlOpener: URLOpener) {
        self.upcomingVoterRegistrationUseCase = upcomingVoterRegistrationUseCase
        self.tabBarItemStylist = tabBarItemStylist
        self.urlOpener = urlOpener

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

        view.addSubview(activityIndicatorView)
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.rowHeight = 44
        tableView.estimatedSectionHeaderHeight = 200
        tableView.registerClass(RegistrationHeaderView.self, forHeaderFooterViewReuseIdentifier: String(RegistrationHeaderView))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: String(UITableViewCell))

        displayResultsUI(false)

        setupConstraints()

        upcomingVoterRegistrationUseCase.fetchUpcomingVoterRegistrations { voterRegistrations in
            self.voterRegistrationInfo = voterRegistrations
            self.tableView.reloadData()
            self.displayResultsUI(true)
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
}

// MARK: UITableViewDelegate
extension VoterRegistrationController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        urlOpener.openURL(voterRegistrationInfo[indexPath.row].url)
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterViewWithIdentifier(String(RegistrationHeaderView))
    }

}

// MARK: UITableViewDataSource
extension VoterRegistrationController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voterRegistrationInfo.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(UITableViewCell), forIndexPath: indexPath)
        cell.textLabel?.text = voterRegistrationInfo[indexPath.row].stateName

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
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.autoPinEdgesToSuperviewEdges()
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
