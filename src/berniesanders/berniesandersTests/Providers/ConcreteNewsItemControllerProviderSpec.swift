import Foundation
import Quick
import Nimble
@testable import berniesanders

class ConcreteNewsItemControllerProviderSpec : QuickSpec {
    var subject : ConcreteNewsItemControllerProvider!
    let humanTimeIntervalFormatter = FakeHumanTimeIntervalFormatter()
    let imageRepository = FakeImageRepository()
    let analyticsService = FakeAnalyticsService()
    let urlOpener = FakeURLOpener()
    let urlAttributionPresenter = FakeURLAttributionPresenter()
    let theme = FakeTheme()

    override func spec() {

        describe("providing an instance with a news item") {
            beforeEach {
                self.subject = ConcreteNewsItemControllerProvider(
                    humanTimeIntervalFormatter: self.humanTimeIntervalFormatter,
                    imageRepository: self.imageRepository,
                    analyticsService: self.analyticsService,
                    urlOpener: self.urlOpener,
                    urlAttributionPresenter: self.urlAttributionPresenter,
                    theme: self.theme
                )
            }

            it("should return a correctly configured instance") {
                let newsItem = NewsItem(title: "a", date: NSDate(), body: "a body", imageURL: NSURL(), url: NSURL())

                let controller = self.subject.provideInstanceWithNewsItem(newsItem)

                expect(controller).to(beAnInstanceOf(NewsItemController.self))
                expect(controller.newsItem).to(beIdenticalTo(newsItem))
                expect(controller.imageRepository as? FakeImageRepository).to(beIdenticalTo(self.imageRepository))
                expect(controller.humanTimeIntervalFormatter as? FakeHumanTimeIntervalFormatter).to(beIdenticalTo(self.humanTimeIntervalFormatter))
                expect(controller.analyticsService as? FakeAnalyticsService).to(beIdenticalTo(self.analyticsService))
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}
