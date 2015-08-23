import berniesanders
import Quick
import Nimble
import UIKit

class IssuesTableViewControllerSpec: QuickSpec {
    var subject: IssuesTableViewController!
    
    override func spec() {
        beforeEach {
            self.subject = IssuesTableViewController()
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("Issues"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("ISSUES"))
        }
    }
}