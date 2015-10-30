import Foundation
import Quick
import Nimble
@testable import berniesanders

class ConcreteNewsItemDeserializerSpec : QuickSpec {
    var subject: ConcreteNewsItemDeserializer!

    override func spec() {
        describe("ConcreteNewsItemDeserializer") {
            beforeEach {
                self.subject = ConcreteNewsItemDeserializer(stringContentSanitizer: FakeStringContentSanitizer())
            }

            it("deserializes the news items correctly with the sanitizer") {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"


                let data = TestUtils.dataFromFixtureFileNamed("news_feed", type: "json")

                let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
                var newsItems = self.subject.deserializeNewsItems(jsonDictionary)

                expect(newsItems.count).to(equal(2))
                let newsItemA = newsItems[0]
                expect(newsItemA.title).to(equal("On the Road for Bernie in Iowa SANITIZED!"))
                var expectedDate = dateFormatter.dateFromString("09-09-2015")
                expect(newsItemA.date).to(equal(expectedDate))
                expect(newsItemA.body).to(equal("Larry Cohen reports from Iowa:\n\nOn a hot Iowa Labor Day weekend, everyone was feeling the Bern! SANITIZED!"))
                expect(newsItemA.imageURL).to(equal(NSURL(string: "https://berniesanders.com/wp-content/uploads/2015/09/iowa-600x250.jpg")))
                expect(newsItemA.url).to(equal(NSURL(string: "https://berniesanders.com/on-the-road-for-bernie-in-iowa/")))

                let newsItemB = newsItems[1]
                expect(newsItemB.title).to(equal("Labor Day 2015: Stand Together and Fight Back SANITIZED!"))
                expectedDate = dateFormatter.dateFromString("07-09-2015")
                expect(newsItemB.date).to(equal(expectedDate))
                expect(newsItemB.body).to(equal("Labor Day is a time for honoring the working people of this country. SANITIZED!"))
                expect(newsItemB.imageURL).to(equal(NSURL(string: "https://berniesanders.com/wp-content/uploads/2015/08/20150818-Bernie-NV-7838-600x250.jpg")))
                expect(newsItemB.url).to(equal(NSURL(string: "https://berniesanders.com/labor-day-2015-stand-together-and-fight-back/")))
            }

            context("when title, body or url are missing") {
                it("should not explode and ignore stories that lack them") {
                    let data = TestUtils.dataFromFixtureFileNamed("dodgy_news_feed", type: "json")

                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
                    var newsItems = self.subject.deserializeNewsItems(jsonDictionary)

                    expect(newsItems.count).to(equal(1))
                    let newsItemA = newsItems[0]
                    expect(newsItemA.title).to(equal("This is good news SANITIZED!"))
                }
            }

            context("when there's not enough hits") {
                it("should not explode") {
                    var newsItems = self.subject.deserializeNewsItems([String: AnyObject]())
                    expect(newsItems.count).to(equal(0))

                    newsItems = self.subject.deserializeNewsItems(["hits": [String: AnyObject]()])
                    expect(newsItems.count).to(equal(0))

                    newsItems = self.subject.deserializeNewsItems(["hits": [ "hits": [String: AnyObject]()]])
                    expect(newsItems.count).to(equal(0));
                }
            }
        }
    }
}
