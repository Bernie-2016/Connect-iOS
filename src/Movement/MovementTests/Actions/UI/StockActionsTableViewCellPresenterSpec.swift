import Quick
import Nimble

@testable import Movement

class StockActionsTableViewCellPresenterSpec: QuickSpec {
    override func spec() {
        fdescribe("StockActionsTableViewCellPresenter") {
            var theme: FakeActionsTableViewPresenterTheme!
            var tableView: UITableView!
            var subject: StockActionsTableViewCellPresenter!
            
            beforeEach {
                theme = FakeActionsTableViewPresenterTheme()
                tableView = UITableView()
                subject = StockActionsTableViewCellPresenter(theme: theme, tableView: tableView)
            }
            
            describe("presenting a 'Movement' action row") {
                describe("when the table view has registered the correct cell type for dequeueing") {
                    context("with zero action alerts") {
                        context("in the donation section") {
                            context("in the donate row") {
                                it("sets the title correctly") {
                                    fail("do it")
                                }
                                
                                it("sets the subtitle correctly") {
                                    fail("do it")
                                }
                                
                                it("sets the icon correctly") {
                                    fail("do it")
                                }
                                
                                it("styles the cell with the theme") {
                                    fail("do it")
                                }
                            }
                            context("in the share the donation for row") {
                                it("sets the title correctly") {
                                    fail("do it")
                                }
                                
                                it("sets the subtitle correctly") {
                                    fail("do it")
                                }
                                
                                it("sets the icon correctly") {
                                    fail("do it")
                                }
                                
                                it("styles the cell with the theme") {
                                    fail("do it")
                                }
                            }
                        }
                        context("in the organize section") {
                            it("sets the title correctly") {
                                fail("do it")
                            }
                            
                            it("sets the subtitle correctly") {
                                fail("do it")
                            }
                            
                            it("sets the icon correctly") {
                                fail("do it")
                            }
                            
                            it("styles the cell with the theme") {
                                fail("do it")
                            }
                        }
                    }
                    
                    context("with action alerts") {
                        
                    }
                    
                }
                
                describe("when the table view has not registered the correct cell type for dequeueing") {
                    it("returns a plain ol' UITableViewCell") {
                        let actionAlerts = [TestUtils.actionAlert()]
                        let cell = subject.presentActionTableViewCell(actionAlerts, indexPath: NSIndexPath(forRow: 0, inSection: 0))
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
                        let cell = subject.presentActionAlertTableViewCell(actionAlert) as! ActionAlertTableViewCell
                        
                        expect(cell.backgroundColor).to(equal(UIColor.magentaColor()))
                        expect(cell.titleLabel.textColor).to(equal(UIColor.purpleColor()))
                        expect(cell.titleLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                        expect(cell.disclosureView.color).to(equal(UIColor.orangeColor()))
                    }
                    
                    it("sets the title from the action alert") {
                        let cell = subject.presentActionAlertTableViewCell(actionAlert) as! ActionAlertTableViewCell
                        
                        expect(cell.titleLabel.text).to(equal("Get to da choppa!"))
                    }
                    
                }
                
                describe("when the table view has not registered the correct cell type for dequeueing") {
                    it("returns a plain ol' UITableViewCell") {
                        let actionAlert = TestUtils.actionAlert()
                        let cell = subject.presentActionAlertTableViewCell(actionAlert)
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
    
    private override func defaultDisclosureColor() -> UIColor {
        return UIColor.orangeColor()
    }
    
    private override func defaultTableCellBackgroundColor() -> UIColor {
        return UIColor.magentaColor()
    }
}