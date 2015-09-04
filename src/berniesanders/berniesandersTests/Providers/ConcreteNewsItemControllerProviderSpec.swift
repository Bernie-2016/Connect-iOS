import Foundation
import Quick
import Nimble
import berniesanders

public class ConcreteNewsItemControllerProviderSpec : QuickSpec {
    var subject : ConcreteNewsItemControllerProvider!
    let dateFormatter = NSDateFormatter()
    let imageRepository = FakeImageRepository()
    let theme = FakeTheme()
    
    override public func spec() {
        
        describe("providing an instance with a news item") {
            beforeEach {
                self.subject = ConcreteNewsItemControllerProvider(
                    dateFormatter: self.dateFormatter,
                    imageRepository: self.imageRepository,
                    theme: self.theme
                )
            }
            
            it("should return a correctly configured instance") {
                let newsItem = NewsItem(title: "a", date: NSDate(), body: "a body", imageURL: NSURL())
                
                let controller = self.subject.provideInstanceWithNewsItem(newsItem)
                
                expect(controller).to(beAnInstanceOf(NewsItemController.self))
                expect(controller.newsItem).to(beIdenticalTo(newsItem))
                expect(controller.dateFormatter).to(beIdenticalTo(self.dateFormatter))
                expect(controller.imageRepository as? FakeImageRepository).to(beIdenticalTo(self.imageRepository))
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}