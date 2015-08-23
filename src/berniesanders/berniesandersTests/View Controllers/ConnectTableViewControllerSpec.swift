import berniesanders
import Quick
import Nimble
import UIKit

class ConnectTableViewControllerSpec: QuickSpec {
    var subject: ConnectTableViewController!
    
    override func spec() {
        beforeEach {
            self.subject = ConnectTableViewController()
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("Connect"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("CONNECT"))
        }
    }
}