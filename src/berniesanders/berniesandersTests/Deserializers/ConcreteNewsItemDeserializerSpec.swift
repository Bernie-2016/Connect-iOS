import Foundation
import Quick
import Nimble
import berniesanders

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
            expect(newsItemA.title).to(equal("On the Road for Bernie in Iowa"))
            expect(newsItemA.date).to(equal(NSDate(timeIntervalSince1970: 1441756800)))
            expect(newsItemA.body).to(equal("Larry Cohen reports from Iowa:\n\nOn a hot Iowa Labor Day weekend, everyone was feeling the Bern!"))
            expect(newsItemA.imageURL).to(equal(NSURL(string: "https://berniesanders.com/wp-content/uploads/2015/09/iowa-600x250.jpg")))
            expect(newsItemA.url).to(equal(NSURL(string: "https://berniesanders.com/on-the-road-for-bernie-in-iowa/")))

            var newsItemB = newsItems[1]
            expect(newsItemB.title).to(equal("Labor Day 2015: Stand Together and Fight Back"))
            expect(newsItemB.date).to(equal(NSDate(timeIntervalSince1970: 1441584000)))
            expect(newsItemB.body).to(equal("Labor Day is a time for honoring the working people of this country."))
            expect(newsItemB.imageURL).to(equal(NSURL(string: "https://berniesanders.com/wp-content/uploads/2015/08/20150818-Bernie-NV-7838-600x250.jpg")))
            expect(newsItemB.url).to(equal(NSURL(string: "https://berniesanders.com/labor-day-2015-stand-together-and-fight-back/")))
        }
        
        context("when an image URL is missing") {
            xit("should not explode") {}
        }
    }
}
