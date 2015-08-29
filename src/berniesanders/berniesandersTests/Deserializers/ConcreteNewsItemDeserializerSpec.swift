import Foundation
import Quick
import Nimble
import berniesanders
import Ono

class ConcreteNewsItemDeserializerSpec : QuickSpec {
    var subject: ConcreteNewsItemDeserializer!
    
    override func spec() {
        beforeEach {
            self.subject = ConcreteNewsItemDeserializer()
        }
        
        it("deserializes the news items correctly") {
            let bundle = NSBundle(forClass: ConcreteIssueDeserializerSpec.self)
            let path = bundle.pathForResource("news_feed", ofType: "json")
            let data = NSData(contentsOfFile: path!)!
            var error: NSError?
            
            let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
            var newsItems = self.subject.deserializeNewsItems(jsonDictionary)

            expect(newsItems.count).to(equal(2))
            var newsItemA = newsItems[0]
            expect(newsItemA.title).to(equal("Jobs with Bernie 2016"))
            expect(newsItemA.date).to(equal(NSDate(timeIntervalSince1970: 1440589188)))
            var newsItemB = newsItems[1]
            expect(newsItemB.title).to(equal("Sanders in North Country Calls on News Media to Cover ‘Real Problems Facing America’"))
            expect(newsItemB.date).to(equal(NSDate(timeIntervalSince1970: 1406284727)))
        }
    }
}
