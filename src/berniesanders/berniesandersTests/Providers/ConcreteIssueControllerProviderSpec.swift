import Foundation
import Quick
import Nimble
import berniesanders

public class ConcreteIssueControllerProviderSpec : QuickSpec {
    var subject : ConcreteIssueControllerProvider!
    let theme = FakeTheme()
    
    override public func spec() {
        
        describe("providing an instance with an issue") {
            beforeEach {
                self.subject = ConcreteIssueControllerProvider(
                    theme: self.theme
                )
            }
            
            it("should return a correctly configured instance") {
                let issue = Issue(title: "a", body: "body", imageURL: NSURL())
                
                let controller = self.subject.provideInstanceWithIssue(issue)
                
                expect(controller).to(beAnInstanceOf(IssueController.self))
                expect(controller.issue).to(beIdenticalTo(issue))
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}