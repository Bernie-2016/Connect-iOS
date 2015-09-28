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
    
    override func tabBarActiveTextColor() -> UIColor {
        return UIColor.purpleColor()
    }
    
    override func tabBarInactiveTextColor() -> UIColor {
        return UIColor.redColor()
    }
    
    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
    
    override func defaultSpinnerColor() -> UIColor {
        return UIColor.greenColor()
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

class FakeIssueControllerProvider : berniesanders.IssueControllerProvider {
    let controller = IssueController(issue: TestUtils.issue(), imageRepository: FakeImageRepository(), theme: FakeTheme())
    var lastIssue: Issue?
    
    func provideInstanceWithIssue(issue: Issue) -> IssueController {
        self.lastIssue = issue;
        return self.controller
    }
}


class IssuesControllerSpec: QuickSpec {
    var subject: IssuesController!
    var issueRepository: FakeIssueRepository! = FakeIssueRepository()
    var issueControllerProvider = FakeIssueControllerProvider()
    let navigationController = UINavigationController()
    let settingsController = TestUtils.settingsController()
    
    override func spec() {
        beforeEach {
            self.subject = IssuesController(
                issueRepository: self.issueRepository,
                issueControllerProvider: self.issueControllerProvider,
                settingsController: self.settingsController,
                theme: IssuesFakeTheme()
            )

            self.navigationController.pushViewController(self.subject, animated: false)
            self.subject.view.layoutSubviews()
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("Issues"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("Issues"))
        }
        
        it("should set the back bar button item title correctly") {
            expect(self.subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
        }
        
        it("styles its tab bar item from the theme") {
            let normalAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Normal)
            
            let normalTextColor = normalAttributes[NSForegroundColorAttributeName] as! UIColor
            let normalFont = normalAttributes[NSFontAttributeName] as! UIFont
            
            expect(normalTextColor).to(equal(UIColor.redColor()))
            expect(normalFont).to(equal(UIFont.systemFontOfSize(123)))
            
            let selectedAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Selected)
            
            let selectedTextColor = selectedAttributes[NSForegroundColorAttributeName] as! UIColor
            let selectedFont = selectedAttributes[NSFontAttributeName] as! UIFont
            
            expect(selectedTextColor).to(equal(UIColor.purpleColor()))
            expect(selectedFont).to(equal(UIFont.systemFontOfSize(123)))
        }
        
        it("initially hides the table view, and shows the loading spinner") {
            expect(self.subject.tableView.hidden).to(equal(true));
            expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(true))
        }
        
        it("has the page components as subviews") {
            let subViews = self.subject.view.subviews as! [UIView]
            
            expect(contains(subViews, self.subject.tableView)).to(beTrue())
            expect(contains(subViews, self.subject.loadingIndicatorView)).to(beTrue())
        }
        
        it("sets the spinner up to hide when stopped") {
            expect(self.subject.loadingIndicatorView.hidesWhenStopped).to(equal(true))
        }
        
        it("styles the spinner from the theme") {
            expect(self.subject.loadingIndicatorView.color).to(equal(UIColor.greenColor()))
        }
        
        describe("tapping on the settings button") {
            it("should push the settings controller onto the nav stack") {
                self.subject.navigationItem.rightBarButtonItem!.tap()
                
                expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.settingsController))
            }
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
                    var issueA = Issue(title: "Big Money in Little DC", body: "body", imageURL: NSURL(string: "http://a.com")!, URL: NSURL(string: "http://b.com")!)
                    var issueB = Issue(title: "Long Live The NHS", body: "body", imageURL: NSURL(string: "http://c.com")!, URL: NSURL(string: "http://d.com")!)
                    
                    self.issueRepository.lastCompletionBlock!([issueA, issueB])
                }
                
                it("shows the table view, and stops the loading spinner") {
                    self.issueRepository.lastCompletionBlock!([])
                    
                    expect(self.subject.tableView.hidden).to(equal(false));
                    expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(false))
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
        
        describe("Tapping on an issue") {
            let expectedIssue = TestUtils.issue()
            
            beforeEach {
                self.subject.view.layoutIfNeeded()
                self.subject.viewWillAppear(false)
                var otherIssue = TestUtils.issue()
                
                var issues = [otherIssue, expectedIssue]
                
                self.issueRepository.lastCompletionBlock!(issues)
            }
            
            it("should push a correctly configured issue controller onto the nav stack") {
                let tableView = self.subject.tableView
                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
 
                expect(self.issueControllerProvider.lastIssue).to(beIdenticalTo(expectedIssue))
                expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.issueControllerProvider.controller))
            }
        }
    }
}