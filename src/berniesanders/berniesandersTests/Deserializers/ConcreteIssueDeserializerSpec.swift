import Foundation
import Quick
import Nimble
import berniesanders
import Ono

class ConcreteIssueDeserializerSpec : QuickSpec {
    var subject: ConcreteIssueDeserializer!
    
    override func spec() {
        beforeEach {
            self.subject = ConcreteIssueDeserializer()
        }
        
        it("deserializes the issues correctly") {
            let bundle = NSBundle(forClass: ConcreteIssueDeserializerSpec.self)
            let path = bundle.pathForResource("issue_feed", ofType: "xml")
            let data = NSData(contentsOfFile: path!)
            var error: NSError?

            let xmlDocument = ONOXMLDocument(data: data, error: &error)

            var issues = self.subject.deserializeIssues(xmlDocument)
            
            expect(issues.count).to(equal(2))
            var issueA = issues[0]
            expect(issueA.title).to(equal("Income and Wealth Inequality"))
            
            var issueB = issues[1]
            expect(issueB.title).to(equal("Getting Big Money Out of Politics"))
        }
    }
}
