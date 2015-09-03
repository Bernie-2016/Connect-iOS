import Foundation
import Quick
import Nimble
import berniesanders

class ConcreteIssueDeserializerSpec : QuickSpec {
    var subject: ConcreteIssueDeserializer!
    
    override func spec() {
        beforeEach {
            self.subject = ConcreteIssueDeserializer()
        }
        
        it("deserializes the issues correctly") {
           let data = TestUtils.dataFromFixtureFileNamed("issue_feed", type: "json")
            var error: NSError?

            
            let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary

            var issues = self.subject.deserializeIssues(jsonDictionary)
            
            expect(issues.count).to(equal(2))
            var issueA = issues[0]
            expect(issueA.title).to(equal("Fighting for Women\u{2019}s Rights"))
            
            var issueB = issues[1]
            expect(issueB.title).to(equal("Reforming Wall Street"))
        }
    }
}
