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
            let path = bundle.pathForResource("news_feed", ofType: "xml")
            let data = NSData(contentsOfFile: path!)
            var error: NSError?
            
            let xmlDocument = ONOXMLDocument(data: data, error: &error)
            
            var newsItems = self.subject.deserializeNewsItems(xmlDocument)
            
            expect(newsItems.count).to(equal(2))
            var newsItemA = newsItems[0]
            expect(newsItemA.title).to(equal("Become a Billboard for Bernie!"))
            expect(newsItemA.date).to(equal(NSDate(timeIntervalSince1970:1440372308)))
            var newsItemB = newsItems[1]
            expect(newsItemB.title).to(equal("Sumter, South Carolina"))
            expect(newsItemB.date).to(equal(NSDate(timeIntervalSince1970:1440262531)))
        }
    }
}
