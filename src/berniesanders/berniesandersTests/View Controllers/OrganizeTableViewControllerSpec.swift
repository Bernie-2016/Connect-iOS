import berniesanders
import Quick
import Nimble
import UIKit

class OrganizeFakeTheme : FakeTheme {
    override func organizeFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }
    
    override func organizeFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    override func organizeFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)
    }
    
    override func organizeFeedDateColor() -> UIColor {
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

class FakeOrganizeItemRepository : berniesanders.OrganizeItemRepository {
    var lastCompletionBlock: ((Array<OrganizeItem>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchOrganizeItemsCalled: Bool = false
    
    init() {
    }
    
    func fetchOrganizeItems(completion: (Array<OrganizeItem>) -> Void, error: (NSError) -> Void) {
        self.fetchOrganizeItemsCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class OrganizeTableViewControllerSpec: QuickSpec {
    var subject: OrganizeTableViewController!
    let organizeItemRepository: FakeOrganizeItemRepository = FakeOrganizeItemRepository()
    
    override func spec() {
        beforeEach {
            let theme = OrganizeFakeTheme()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle

            self.subject = OrganizeTableViewController(
                theme: theme,
                organizeItemRepository: self.organizeItemRepository,
                dateFormatter: dateFormatter
            )
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("Organize"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("ORGANIZE"))
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
            
            it("asks the organize  item repository for some organize items") {
                expect(self.organizeItemRepository.fetchOrganizeItemsCalled).to(beTrue())
            }
            
            describe("when the organize repository returns some organize items") {
                var organizationItemADate = NSDate(timeIntervalSince1970: 0)
                var organizationItemBDate = NSDate(timeIntervalSince1970: 86401)
                
                beforeEach {
                    var organizeItemA = OrganizeItem(title: "Florida call to action", date: organizationItemADate)
                    var organizeItemB = OrganizeItem(title: "National call to action", date: organizationItemBDate)
                    
                    var organizeItems = [organizeItemA, organizeItemB]
                    self.organizeItemRepository.lastCompletionBlock!(organizeItems)
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