import berniesanders
import Quick
import Nimble
import UIKit

class OrganizeTableViewControllerSpec: QuickSpec {
    var subject: OrganizeTableViewController!
    
    override func spec() {
        beforeEach {
            self.subject = OrganizeTableViewController()
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("Organize"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("ORGANIZE"))
        }
    }
}