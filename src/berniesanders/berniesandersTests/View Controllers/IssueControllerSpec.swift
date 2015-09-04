import UIKit
import Quick
import Nimble
import berniesanders

class IssueFakeTheme : FakeTheme {
    override func issueTitleFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)
    }
    
    override func issueTitleColor() -> UIColor {
        return UIColor.brownColor()
    }
    
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }
}


class IssueControllerSpec : QuickSpec {
    var subject : IssueController!
    let issue = Issue(title: "Some issue")
    
    override func spec() {
        beforeEach {
            self.subject = IssueController(issue: self.issue, theme: IssueFakeTheme())
        }
        
        it("should hide the tab bar when pushed") {
            expect(self.subject.hidesBottomBarWhenPushed).to(beTrue())
        }

        describe("when the view loads") {
            beforeEach {
                self.subject.view.layoutIfNeeded()
            }
            
            it("has a scroll view containing the UI elements") {
                expect(self.subject.view.subviews.count).to(equal(1))
                var scrollView = self.subject.view.subviews.first as! UIScrollView
                
                expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                expect(scrollView.subviews.count).to(equal(1))
                
                var containerView = scrollView.subviews.first as! UIView
                
                expect(containerView.subviews.count).to(equal(1))
                
                var containerViewSubViews = containerView.subviews as! [UIView]
                
                expect(contains(containerViewSubViews, self.subject.titleLabel)).to(beTrue())
            }
            
            it("displays the title from the issue") {
                expect(self.subject.titleLabel.text).to(equal("Some issue"))
            }
            
            it("styles the views according to the theme") {
                expect(self.subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                expect(self.subject.titleLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                expect(self.subject.titleLabel.textColor).to(equal(UIColor.brownColor()))
            }
        }
    }
}
