import Quick
import Nimble

@testable import Connect

class StockActionsTableViewCellPresenterSpec: QuickSpec {
    override func spec() {
        sharedExamples("a correctly styled action cell") { (sharedExampleContext: SharedExampleContext) in
            var cell: ActionTableViewCell!

            beforeEach {
                cell = sharedExampleContext()["cell"] as! ActionTableViewCell
            }

            it("styles the cell with the theme") {
                expect(cell.backgroundColor).to(equal(UIColor.redColor()))
                expect(cell.titleLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                expect(cell.titleLabel.textColor).to(equal(UIColor.purpleColor()))
                expect(cell.subTitleLabel.font).to(equal(UIFont.systemFontOfSize(222)))
                expect(cell.subTitleLabel.textColor).to(equal(UIColor.magentaColor()))
                expect(cell.disclosureView.color).to(equal(UIColor.orangeColor()))
            }
        }

        describe("StockActionsTableViewCellPresenter") {
            var theme: FakeActionsTableViewPresenterTheme!
            var tableView: UITableView!
            var subject: ActionsTableViewCellPresenter!

            beforeEach {
                theme = FakeActionsTableViewPresenterTheme()
                tableView = UITableView()
                subject = StockActionsTableViewCellPresenter(theme: theme)
            }

            describe("presenting a 'Connect' action row") {
                describe("when the table view has registered the correct cell type for dequeueing") {
                    beforeEach { tableView.registerClass(ActionTableViewCell.self, forCellReuseIdentifier: "actionCell") }
                    context("with zero action alerts") {
                        let actionAlerts = [ActionAlert]()
                        var sharedExampleContext: Dictionary<String, AnyObject>!

                        context("in the donation section") {
                            let section = 0

                            context("in the donate row") {
                                let row = 0
                                var cell: ActionTableViewCell!

                                beforeEach {
                                    let indexPath = NSIndexPath(forRow: row, inSection: section)
                                    cell = subject.presentActionTableViewCell(actionAlerts, indexPath: indexPath, tableView: tableView) as! ActionTableViewCell
                                    sharedExampleContext = [ "cell": cell ]
                                }


                                it("sets the title correctly") {
                                    expect(cell.titleLabel.text).to(equal("Donate to the Campaign"))
                                }

                                it("sets the subtitle correctly") {
                                    expect(cell.subTitleLabel.text).to(equal("Contribute via the campaign website"))
                                }

                                itBehavesLike("a correctly styled action cell") { sharedExampleContext }
                            }

                            context("in the share the donation for row") {
                                let row = 1
                                var cell: ActionTableViewCell!

                                beforeEach {
                                    let indexPath = NSIndexPath(forRow: row, inSection: section)
                                    cell = subject.presentActionTableViewCell(actionAlerts, indexPath: indexPath, tableView: tableView) as! ActionTableViewCell
                                    sharedExampleContext = [ "cell": cell ]                                }

                                it("sets the title correctly") {
                                    expect(cell.titleLabel.text).to(equal("Share the Donate page"))
                                }

                                it("sets the subtitle correctly") {
                                    expect(cell.subTitleLabel.text).to(equal("Ask friends and family to donate"))
                                }

                                itBehavesLike("a correctly styled action cell") { sharedExampleContext }
                            }
                        }

                        context("in the organize section") {
                            var cell: ActionTableViewCell!

                            beforeEach {
                                let indexPath = NSIndexPath(forRow: 0, inSection: 1)
                                cell = subject.presentActionTableViewCell(actionAlerts, indexPath: indexPath, tableView: tableView) as! ActionTableViewCell
                                sharedExampleContext = [ "cell": cell ]
                            }

                            it("sets the title correctly") {
                                expect(cell.titleLabel.text).to(equal("Host an event"))
                            }

                            it("sets the subtitle correctly") {
                                expect(cell.subTitleLabel.text).to(equal("Organize supporters in your area"))
                            }

                            itBehavesLike("a correctly styled action cell") { sharedExampleContext }
                        }
                    }

                    context("with action alerts") {
                        let actionAlerts = [TestUtils.actionAlert()]
                        var sharedExampleContext: Dictionary<String, AnyObject>!

                        context("in the donation section") {
                            let section = 1

                            context("in the donate row") {
                                let row = 0
                                var cell: ActionTableViewCell!

                                beforeEach {
                                    let indexPath = NSIndexPath(forRow: row, inSection: section)
                                    cell = subject.presentActionTableViewCell(actionAlerts, indexPath: indexPath, tableView: tableView) as! ActionTableViewCell
                                    sharedExampleContext = [ "cell": cell ]
                                }


                                it("sets the title correctly") {
                                    expect(cell.titleLabel.text).to(equal("Donate to the Campaign"))
                                }

                                it("sets the subtitle correctly") {
                                    expect(cell.subTitleLabel.text).to(equal("Contribute via the campaign website"))
                                }

                                itBehavesLike("a correctly styled action cell") { sharedExampleContext }
                            }

                            context("in the share the donation for row") {
                                let row = 1
                                var cell: ActionTableViewCell!

                                beforeEach {
                                    let indexPath = NSIndexPath(forRow: row, inSection: section)
                                    cell = subject.presentActionTableViewCell(actionAlerts, indexPath: indexPath, tableView: tableView) as! ActionTableViewCell
                                    sharedExampleContext = [ "cell": cell ]                                }

                                it("sets the title correctly") {
                                    expect(cell.titleLabel.text).to(equal("Share the Donate page"))
                                }

                                it("sets the subtitle correctly") {
                                    expect(cell.subTitleLabel.text).to(equal("Ask friends and family to donate"))
                                }

                                itBehavesLike("a correctly styled action cell") { sharedExampleContext }
                            }
                        }

                        context("in the organize section") {
                            var cell: ActionTableViewCell!

                            beforeEach {
                                let indexPath = NSIndexPath(forRow: 0, inSection: 2)
                                cell = subject.presentActionTableViewCell(actionAlerts, indexPath: indexPath, tableView: tableView) as! ActionTableViewCell
                                sharedExampleContext = [ "cell": cell ]
                            }

                            it("sets the title correctly") {
                                expect(cell.titleLabel.text).to(equal("Host an event"))
                            }

                            it("sets the subtitle correctly") {
                                expect(cell.subTitleLabel.text).to(equal("Organize supporters in your area"))
                            }

                            itBehavesLike("a correctly styled action cell") { sharedExampleContext }
                        }
                    }
                }

                describe("when the table view has not registered the correct cell type for dequeueing") {
                    it("returns a plain ol' UITableViewCell") {
                        let actionAlerts = [TestUtils.actionAlert()]
                        let cell = subject.presentActionTableViewCell(actionAlerts, indexPath: NSIndexPath(forRow: 0, inSection: 0), tableView: tableView)
                        expect(cell).to(beAnInstanceOf(UITableViewCell.self))
                    }
                }
            }

            describe("presenting an action alert row") {
                describe("when the table view has registered the correct cell type for dequeueing") {
                    var actionAlert: ActionAlert!

                    beforeEach {
                        actionAlert = TestUtils.actionAlert("Get to da choppa!")
                        tableView.registerClass(ActionAlertTableViewCell.self, forCellReuseIdentifier: "actionAlertCell")
                    }

                    it("style the cell using the theme") {
                        let cell = subject.presentActionAlertTableViewCell(actionAlert, tableView: tableView) as! ActionAlertTableViewCell

                        expect(cell.backgroundColor).to(equal(UIColor.redColor()))
                        expect(cell.titleLabel.textColor).to(equal(UIColor.purpleColor()))
                        expect(cell.titleLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                        expect(cell.disclosureView.color).to(equal(UIColor.orangeColor()))
                    }

                    it("sets the title from the action alert") {
                        let cell = subject.presentActionAlertTableViewCell(actionAlert, tableView: tableView) as! ActionAlertTableViewCell

                        expect(cell.titleLabel.text).to(equal("Get to da choppa!"))
                    }

                }

                describe("when the table view has not registered the correct cell type for dequeueing") {
                    it("returns a plain ol' UITableViewCell") {
                        let actionAlert = TestUtils.actionAlert()
                        let cell = subject.presentActionAlertTableViewCell(actionAlert, tableView: tableView)
                        expect(cell).to(beAnInstanceOf(UITableViewCell.self))
                    }
                }
            }
        }
    }
}

private class FakeActionsTableViewPresenterTheme: FakeTheme {
    private override func actionsTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(111)
    }

    private override func actionsTitleTextColor() -> UIColor {
        return UIColor.purpleColor()
    }

    private override func actionsSubTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(222)
    }

    private override func actionsSubTitleTextColor() -> UIColor {
        return UIColor.magentaColor()
    }

    private override func defaultDisclosureColor() -> UIColor {
        return UIColor.orangeColor()
    }

    private override func defaultTableCellBackgroundColor() -> UIColor {
        return UIColor.redColor()
    }
}
