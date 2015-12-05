import Foundation
import Quick
import Nimble
@testable import Movement

class ConcreteNewsFeedItemControllerProviderSpec : QuickSpec {
    var subject : ConcreteNewsFeedItemControllerProvider!
    let timeIntervalFormatter = FakeTimeIntervalFormatter()
    let imageRepository = FakeImageRepository()
    let analyticsService = FakeAnalyticsService()
    let urlOpener = FakeURLOpener()
    let urlAttributionPresenter = FakeURLAttributionPresenter()
    let theme = FakeTheme()

    override func spec() {

        describe("providing an instance with a news item") {
            beforeEach {
                self.subject = ConcreteNewsFeedItemControllerProvider(
                    timeIntervalFormatter: self.timeIntervalFormatter,
                    imageRepository: self.imageRepository,
                    analyticsService: self.analyticsService,
                    urlOpener: self.urlOpener,
                    urlAttributionPresenter: self.urlAttributionPresenter,
                    theme: self.theme
                )
            }

            it("should return a correctly configured instance") {
                let newsArticle = NewsArticle(title: "a", date: NSDate(), body: "a body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL())

                let controller = self.subject.provideInstanceWithNewsFeedItem(newsArticle) as! NewsArticleController

                expect(controller.newsArticle).to(beIdenticalTo(newsArticle))
                expect(controller.imageRepository as? FakeImageRepository).to(beIdenticalTo(self.imageRepository))
                expect(controller.timeIntervalFormatter as? FakeTimeIntervalFormatter).to(beIdenticalTo(self.timeIntervalFormatter))
                expect(controller.analyticsService as? FakeAnalyticsService).to(beIdenticalTo(self.analyticsService))
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}
