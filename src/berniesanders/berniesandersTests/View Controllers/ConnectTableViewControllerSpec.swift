import berniesanders
import Quick
import Nimble
import UIKit

class ConnectFakeTheme : FakeTheme {
    override func connectFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }
    
    override func connectFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    override func connectFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)
    }
    
    override func connectFeedDateColor() -> UIColor {
        return UIColor.brownColor()
    }
    
    override func feedHeaderBackgroundColor() -> UIColor {
        return UIColor.yellowColor()
    }
    
    override func feedHeaderTextColor() -> UIColor {
        return UIColor.orangeColor()
    }
    
    override func feedHeaderFont() -> UIFont {
        return UIFont.systemFontOfSize(8)
    }
    
    override func tabBarTextColor() -> UIColor {
        return UIColor.purpleColor()
    }
    
    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
}

class FakeConnectItemRepository : berniesanders.ConnectItemRepository {
    var lastCompletionBlock: ((Array<ConnectItem>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchConnectItemsCalled: Bool = false
    
    init() {
    }
    
    func fetchConnectItems(completion: (Array<ConnectItem>) -> Void, error: (NSError) -> Void) {
        self.fetchConnectItemsCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class ConnectTableViewControllerSpec: QuickSpec {
    var subject: ConnectTableViewController!
    let connectItemRepository: FakeConnectItemRepository = FakeConnectItemRepository()
    
    override func spec() {
        beforeEach {
            let theme = ConnectFakeTheme()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle

            self.subject = ConnectTableViewController(
                theme: theme,
                connectItemRepository: self.connectItemRepository,
                dateFormatter: dateFormatter
            )
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("Connect"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("CONNECT"))
        }
        
        it("styles its tab bar item from the theme") {
            let normalAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Normal)
            
            let normalTextColor = normalAttributes[NSForegroundColorAttributeName] as! UIColor
            let normalFont = normalAttributes[NSFontAttributeName] as! UIFont
            
            expect(normalTextColor).to(equal(UIColor.purpleColor()))
            expect(normalFont).to(equal(UIFont.systemFontOfSize(123)))
            
            let selectedAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Selected)
            
            let selectedTextColor = selectedAttributes[NSForegroundColorAttributeName] as! UIColor
            let selectedFont = selectedAttributes[NSFontAttributeName] as! UIFont
            
            expect(selectedTextColor).to(equal(UIColor.purpleColor()))
            expect(selectedFont).to(equal(UIFont.systemFontOfSize(123)))
        }
        
        describe("when the controller appears") {
            beforeEach {
                self.subject.view.layoutIfNeeded()
                self.subject.viewWillAppear(false)
            }
            
            it("has the correctly styled header for the table") {
                var tableHeader = self.subject.tableView.headerViewForSection(0) as! TableHeaderView
                expect(tableHeader.titleLabel.text).to(equal("District text goes here"))
                
                expect(tableHeader.contentView.backgroundColor).to(equal(UIColor.yellowColor()))
                expect(tableHeader.titleLabel.textColor).to(equal(UIColor.orangeColor()))
                expect(tableHeader.titleLabel.font).to(equal(UIFont.systemFontOfSize(8)))
            }
            
            it("has an empty table") {
                expect(self.subject.tableView.numberOfSections()).to(equal(1))
                expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(0))
            }
            
            it("asks the connect item repository for some connect items") {
                expect(self.connectItemRepository.fetchConnectItemsCalled).to(beTrue())
            }
            
            describe("when the connect repository returns some connect items") {
                var connectItemADate = NSDate(timeIntervalSince1970: 0)
                var connectItemBDate = NSDate(timeIntervalSince1970: 86401)
                
                beforeEach {
                    var connectItemA = ConnectItem(title: "Florida call to action", date: connectItemADate)
                    var connectItemB = ConnectItem(title: "National call to action", date: connectItemBDate)
                    
                    var connectItems = [connectItemA, connectItemB]
                    self.connectItemRepository.lastCompletionBlock!(connectItems)
                }
                
                it("shows the items in the table with upcased text") {
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))
                    
                    var cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellA.titleLabel.text).to(equal("FLORIDA CALL TO ACTION"))
                    expect(cellA.dateLabel.text).to(equal("12/31/69"))
                    
                    var cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellB.titleLabel.text).to(equal("NATIONAL CALL TO ACTION"))
                    expect(cellB.dateLabel.text).to(equal("1/1/70"))
                }
                
                it("styles the items in the table") {
                    var cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TitleSubTitleTableViewCell
                    
                    expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                    expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    expect(cell.dateLabel.textColor).to(equal(UIColor.brownColor()))
                    expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                }
            }
        }

    }
}