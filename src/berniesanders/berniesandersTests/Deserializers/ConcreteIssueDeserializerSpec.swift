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
            expect(issueA.body).to(equal("Despite major advances in civil and political rights, our country still has a long way to go in addressing the issue of gender inequality."))
            expect(issueA.imageURL).to(equal(NSURL(string: "https://berniesanders.com/wp-content/uploads/2015/08/20150814_Bernie_WingDing-6675.jpg")))
            
            var issueB = issues[1]
            expect(issueB.title).to(equal("Reforming Wall Street"))
            expect(issueB.body).to(equal("Wall Street cannot continue to be an island unto itself, gambling trillions in risky financial instruments while expecting the public to bail it out."))
            expect(issueB.imageURL).to(equal(NSURL(string: "https://s.bsd.net/bernie16/main/page/-/website/fb-share.png")))

        }
        
        context("when an image URL is missing") {
            xit("should not explode") {}
        }
    }
}
