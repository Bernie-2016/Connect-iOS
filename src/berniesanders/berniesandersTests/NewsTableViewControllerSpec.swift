import berniesanders
import Quick
import Nimble
import UIKit

class NewsTableViewControllerSpecs: QuickSpec {
    var subject: NewsTableViewController!

    override func spec() {
        
        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.subject = storyboard.instantiateViewControllerWithIdentifier("NewsTableViewController") as! NewsTableViewController
            self.subject.beginAppearanceTransition(true, animated: false)
            self.subject.endAppearanceTransition()
        }
    
        it("successfully loads from the storyboard") {
            expect(self.subject).toNot(beNil())
        }
    }
}

