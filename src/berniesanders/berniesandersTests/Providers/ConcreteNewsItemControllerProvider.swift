import Foundation
import Quick
import Nimble
import berniesanders

public class ConcreteNewsItemControllerProviderSpec : QuickSpec {
    var subject : ConcreteNewsItemControllerProvider!
    
    override public func spec() {
        describe("providing an instance with a news item") {
            beforeEach {
                self.subject = ConcreteNewsItemControllerProvider()
            }
            
            it("should return a correctly configured instance") {
                let newsItem = NewsItem(title: "a", date: NSDate())
                
                let controller = self.subject.provideInstanceWithNewsItem(newsItem)
                
                expect(controller).to(beAnInstanceOf(NewsItemController.self))
                expect(controller.newsItem).to(beIdenticalTo(newsItem))
            }
        }
    }
}