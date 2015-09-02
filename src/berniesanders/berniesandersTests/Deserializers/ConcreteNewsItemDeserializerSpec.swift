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
            expect(newsItemA.body).to(equal("Bernie 2016 is an equal opportunity employer; women, people of color, and people with disabilities are strongly encouraged to apply."))
            expect(newsItemA.imageURL).to(equal(NSURL(string: "https://berniesanders.com/wp-content/uploads/2015/07/20150704_Bernie_Iowa_IMG_2327.jpg")))

            var newsItemB = newsItems[1]
            expect(newsItemB.title).to(equal("Sanders in North Country Calls on News Media to Cover ‘Real Problems Facing America’"))
            expect(newsItemB.date).to(equal(NSDate(timeIntervalSince1970: 1406284727)))
            expect(newsItemB.body).to(equal("LITTLETON, N.H. \u{2013} Speaking to packed town meetings across northern New Hampshire on Monday, U.S. Sen. Bernie Sanders urged the news media to focus on important issues like jobs, income and wealth inequality, climate change, racism, college costs, retirement security, criminal justice and poverty in America."))
            expect(newsItemB.imageURL).to(equal(NSURL(string: "https://s.bsd.net/bernie16/main/page/-/website/fb-share.png")))
        }
        
        context("when an image URL is missing") {
            xit("should not explode") {}
        }
    }
}
