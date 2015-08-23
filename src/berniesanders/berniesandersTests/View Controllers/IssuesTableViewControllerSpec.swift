import berniesanders
import Quick
import Nimble
import UIKit

class IssuesFakeTheme : FakeTheme {
    override func issuesFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }
    
    override func issuesFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }
}

class FakeIssueRepository : berniesanders.IssueRepository {
    var lastCompletionBlock: ((Array<Issue>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchIssuesCalled: Bool = false
    
    init() {
    }
    
    func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        self.fetchIssuesCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}


class IssuesTableViewControllerSpec: QuickSpec {
    var subject: IssuesTableViewController!
    var issueRepository: FakeIssueRepository! = FakeIssueRepository()
    
    override func spec() {
        beforeEach {
            self.subject = IssuesTableViewController(
                issueRepository: self.issueRepository,
                theme: IssuesFakeTheme()
            )
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("Issues"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("ISSUES"))
        }
        
        describe("when the controller appears") {
            beforeEach {
                self.subject.view.layoutIfNeeded()
                self.subject.viewWillAppear(false)
            }
            
            it("has an empty table") {
                expect(self.subject.tableView.numberOfSections()).to(equal(1))
                expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(0))
            }
            
            it("asks the issue repository for some news") {
                expect(self.issueRepository.fetchIssuesCalled).to(beTrue())
            }
            
            
            describe("when the issue repository returns some issues") {
                beforeEach {
                    var issueA = Issue(title: "Big Money in Little DC")
                    var issueB = Issue(title: "Long Live The NHS")
                    
                    self.issueRepository.lastCompletionBlock!([issueA, issueB])
                }
                
                it("shows the issues in the table") {
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))
                    
                    var cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IssueTableViewCell
                    expect(cellA.titleLabel.text).to(equal("Big Money in Little DC"))
                    
                    var cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! IssueTableViewCell
                    expect(cellB.titleLabel.text).to(equal("Long Live The NHS"))
                }
                
                it("styles the items in the table") {
                    var cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IssueTableViewCell
                    
                    expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                    expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))                 
                }
            }
        }
    }
}