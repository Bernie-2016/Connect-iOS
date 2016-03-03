import Quick
import Nimble

@testable import Connect

class ActionsControllerSpec: QuickSpec {
    override func spec() {
        describe("ActionsController") {
            var subject: ActionsController!
            var urlProvider: URLProvider!
            var urlOpener: FakeURLOpener!
            var actionAlertService: FakeActionAlertService!
            var actionAlertControllerProvider: FakeActionAlertControllerProvider!
            var actionsTableViewCellPresenter: FakeActionsTableViewCellPresenter!
            var analyticsService: FakeAnalyticsService!
            var tabBarItemStylist: FakeTabBarItemStylist!
            var theme: Theme!

            var navigationController: UINavigationController!

            beforeEach {
                urlProvider = ActionsControllerFakeURLProvider()
                urlOpener = FakeURLOpener()
                actionAlertService = FakeActionAlertService()
                actionAlertControllerProvider = FakeActionAlertControllerProvider()
                actionsTableViewCellPresenter = FakeActionsTableViewCellPresenter()
                analyticsService = FakeAnalyticsService()
                tabBarItemStylist = FakeTabBarItemStylist()

                theme = ActionsControllerFakeTheme()

                subject = ActionsController(
                    urlProvider: urlProvider,
                    urlOpener: urlOpener,
                    actionAlertService: actionAlertService,
                    actionAlertControllerProvider: actionAlertControllerProvider,
                    actionsTableViewCellPresenter: actionsTableViewCellPresenter,
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    theme: theme)

                navigationController = UINavigationController(rootViewController: subject)
                expect(subject.view).toNot(beNil())
            }

            context("when the view appears") {
                beforeEach {
                    subject.viewWillAppear(false)
                }

                it("has the correct title") {
                    expect(subject.title).to(equal("Act Now"))
                }

                it("should set the back bar button item title correctly") {
                    expect(subject.navigationItem.backBarButtonItem?.title).to(equal(""))
                }

                it("uses the tab bar item stylist to style its tab bar item") {
                    expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                    expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "actionsTabBarIconInactive")))
                    expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "actionsTabBarIcon")))
                }

                it("has a table view styled with the theme") {
                    expect(subject.view.subviews.count).to(equal(2))

                    let tableView = subject.view.subviews.first!
                    expect(tableView).to(beAnInstanceOf(UITableView.self))
                    expect(tableView.backgroundColor).to(equal(UIColor.orangeColor()))
                }

                it("initially hides the table view, and shows the loading spinner") {
                    let tableView = subject.view.subviews.first! as! UITableView
                    expect(tableView.hidden).to(equal(true));
                    expect(subject.view.subviews).to(contain(subject.loadingIndicatorView))
                    expect(subject.loadingIndicatorView.isAnimating()).to(equal(true))
                }

                it("sets the spinner up to hide when stopped") {
                    expect(subject.loadingIndicatorView.hidesWhenStopped).to(equal(true))
                }

                it("styles the spinner with the theme") {
                    expect(subject.loadingIndicatorView.color).to(equal(UIColor.greenColor()))
                }

                it("makes a request to the action alert service") {
                    expect(actionAlertService.fetchActionAlertsCalled).to(beTrue())
                }

                describe("when the request to the action alert service succeeds") {
                    context("and the service resolves its promise with action alerts") {
                        var tableView: UITableView!
                        let firstActionAlert = TestUtils.actionAlert("FTB!")
                        let secondActionAlert = TestUtils.actionAlert("Aha!")

                        beforeEach {
                            let actionAlerts = [ firstActionAlert, secondActionAlert ]

                            actionAlertService.lastReturnedActionAlertsPromise.resolve(actionAlerts)

                            tableView = subject.view.subviews.first! as! UITableView
                        }

                        it("has a row per action alert, provided by the presenter") {
                            expect(tableView.numberOfRowsInSection(0)).to(equal(2))

                            let firstCell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                            expect(actionsTableViewCellPresenter.lastActionAlert).to(equal(firstActionAlert))
                            expect(actionsTableViewCellPresenter.lastActionAlertTableView).to(beIdenticalTo(tableView))
                            expect(firstCell).to(beIdenticalTo(actionsTableViewCellPresenter.lastReturnedActionAlertTableViewCell))


                            let secondCell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                            expect(actionsTableViewCellPresenter.lastActionAlert).to(equal(secondActionAlert))
                            expect(actionsTableViewCellPresenter.lastActionAlertTableView).to(beIdenticalTo(tableView))
                            expect(secondCell).to(beIdenticalTo(actionsTableViewCellPresenter.lastReturnedActionAlertTableViewCell))
                        }

                        describe("tapping on an action alert row") {
                            it("asks the action alert controller provider for a controller") {
                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                                expect(actionAlertControllerProvider.lastActionAlertReceived).to(equal(firstActionAlert))
                            }

                            it("pushes the controller from the action alert controller provider onto the nav stack") {
                                expect(navigationController.topViewController).to(beIdenticalTo(subject))

                                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                                expect(navigationController.topViewController).to(beIdenticalTo(actionAlertControllerProvider.returnedController))
                            }
                        }
                    }
                }
            }
        }
    }
}


private class ActionsControllerFakeURLProvider: FakeURLProvider {
    override func donateFormURL() -> NSURL {
        return NSURL(string: "https://example.com/donate")!
    }

    private override func hostEventFormURL() -> NSURL {
        return NSURL(string: "https://example.com/host")!
    }
}

private class ActionsControllerFakeTheme: FakeTheme {
    override func defaultBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func defaultTableSectionHeaderBackgroundColor() -> UIColor { return UIColor.darkGrayColor() }
    override func defaultTableSectionHeaderTextColor() -> UIColor { return UIColor.lightGrayColor() }
    override func defaultTableSectionHeaderFont() -> UIFont { return UIFont.italicSystemFontOfSize(999) }
    override func defaultTableCellBackgroundColor() -> UIColor { return UIColor.yellowColor() }
    override func defaultSpinnerColor() -> UIColor { return UIColor.greenColor() }
}

private class FakeActionsTableViewCellPresenter: ActionsTableViewCellPresenter {
    var lastActionAlert: ActionAlert!
    var lastActionAlertTableView: UITableView!
    var lastReturnedActionAlertTableViewCell: UITableViewCell!
    func presentActionAlertTableViewCell(actionAlert: ActionAlert, tableView: UITableView) -> UITableViewCell {
        lastActionAlert = actionAlert
        lastActionAlertTableView = tableView
        lastReturnedActionAlertTableViewCell = UITableViewCell()
        return lastReturnedActionAlertTableViewCell
    }

    var lastActionActionAlerts: [ActionAlert]!
    var lastActionIndexPath: NSIndexPath!
    var lastActionTableView: UITableView!
    var lastReturnedActionTableViewCell: UITableViewCell!
    func presentActionTableViewCell(actionAlerts: [ActionAlert], indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell {
        lastActionActionAlerts = actionAlerts
        lastActionIndexPath = indexPath
        lastActionTableView = tableView
        lastReturnedActionTableViewCell = UITableViewCell()
        return lastReturnedActionTableViewCell
    }
}

private class ActionAlertsWrapper {
    let actionAlerts: [ActionAlert]
    init(actionAlerts: [ActionAlert]) {
        self.actionAlerts = actionAlerts
    }
}
