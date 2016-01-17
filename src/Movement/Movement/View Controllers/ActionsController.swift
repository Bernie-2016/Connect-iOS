import UIKit

class ActionsController: UIViewController {
    private let urlProvider: URLProvider
    private let urlOpener: URLOpener
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    private let tableView = UITableView.newAutoLayoutView()

    init(urlProvider: URLProvider, urlOpener: URLOpener, analyticsService: AnalyticsService, tabBarItemStylist: TabBarItemStylist, theme: Theme) {
        self.urlProvider = urlProvider
        self.urlOpener = urlOpener
        self.analyticsService = analyticsService
        self.tabBarItemStylist = tabBarItemStylist
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Actions_title", comment: "")
        tabBarItemStylist.applyThemeToBarBarItem(tabBarItem,
            image: UIImage(named: "actionsTabBarIconInactive")!,
            selectedImage: UIImage(named: "actionsTabBarIcon")!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(ActionTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerClass(ActionsSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = theme.defaultBackgroundColor()

        setupConstraints()
    }

    // MARK: Private

    private func setupConstraints() {
        tableView.autoPinEdgesToSuperviewEdges()
    }
}

extension ActionsController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? ActionTableViewCell else { return UITableViewCell() }
        var titleKey: String!
        var subTitleKey: String!
        var imageName: String!
        if indexPath.section == 0 {
            titleKey = indexPath.row == 0 ? "Actions_donateTitle" : "Actions_shareDonateTitle"
            subTitleKey = indexPath.row == 0 ? "Actions_donateSubTitle" : "Actions_shareDonateSubTitle"
            imageName = indexPath.row == 0 ? "Donate" : "ShareDonate"
        } else {
            titleKey = "Actions_hostEventTitle"
            subTitleKey = "Actions_hostEventSubTitle"
            imageName = "HostEvent"

            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        }

        cell.backgroundColor = theme.defaultTableCellBackgroundColor()
        cell.titleLabel.text = NSLocalizedString(titleKey, comment: "")
        cell.subTitleLabel.text = NSLocalizedString(subTitleKey, comment: "")
        cell.iconImageView.image = UIImage(named: imageName)

        cell.titleLabel.font = theme.actionsTitleFont()
        cell.titleLabel.textColor = theme.actionsTitleTextColor()
        cell.subTitleLabel.font = theme.actionsSubTitleFont()
        cell.subTitleLabel.textColor = theme.actionsSubTitleTextColor()
        cell.disclosureView.color = theme.defaultDisclosureColor()

        return cell
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") else {
            return nil
        }

        headerView.textLabel!.text = NSLocalizedString(section == 0 ? "Actions_fundraiseHeader" : "Actions_organizeHeader", comment: "")
        headerView.contentView.backgroundColor = self.theme.defaultTableSectionHeaderBackgroundColor()
        headerView.textLabel?.textColor = self.theme.defaultTableSectionHeaderTextColor()
        headerView.textLabel?.font = self.theme.defaultTableSectionHeaderFont()

        return headerView
    }
}

extension ActionsController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 41
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                openFormInSafari("Donate Form", url: urlProvider.donateFormURL())
            } else {
                shareDonateForm()
            }
        } else {
            openFormInSafari("Host Event Form", url: urlProvider.hostEventFormURL())
        }
    }

    private func openFormInSafari(name: String, url: NSURL) {
        urlOpener.openURL(url)
        analyticsService.trackContentViewWithName(name, type: .Actions, identifier: name)

    }
    private func shareDonateForm() {
        let name = "Donate Form"
        let url = urlProvider.donateFormURL()
        self.analyticsService.trackCustomEventWithName("Began Share", customAttributes: [
        AnalyticsServiceConstants.contentIDKey: url.absoluteString,
        AnalyticsServiceConstants.contentNameKey: name,
        AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.Actions.description
        ])
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if error != nil {
                self.analyticsService.trackError(error!, context: "Failed to share \(name)")
            } else {
                if success == true {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: name, contentType: .Actions, identifier: url.absoluteString)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled Share", customAttributes: [AnalyticsServiceConstants.contentIDKey: url.absoluteString,
                        AnalyticsServiceConstants.contentNameKey: name,
                        AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.Actions.description
                        ])
                }
            }
        }

        presentViewController(activityVC, animated: true, completion: nil)
    }
}
