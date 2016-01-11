import Foundation
import Quick
import Nimble
@testable import Movement

class ConcreteNewsFeedItemControllerProviderSpec : QuickSpec {
    override func spec() {
        describe("ConcreteNewsFeedItemControllerProvider") {
            var subject : ConcreteNewsFeedItemControllerProvider!
            let timeIntervalFormatter = FakeTimeIntervalFormatter()
            let imageService = FakeImageService()
            let analyticsService = FakeAnalyticsService()
            let urlOpener = FakeURLOpener()
            let urlAttributionPresenter = FakeURLAttributionPresenter()
            let urlProvider = FakeURLProvider()
            let theme = FakeTheme()

            describe("providing an instance with a news item") {
                beforeEach {
                    subject = ConcreteNewsFeedItemControllerProvider(
                        timeIntervalFormatter: timeIntervalFormatter,
                        imageService: imageService,
                        analyticsService: analyticsService,
                        urlOpener: urlOpener,
                        urlAttributionPresenter: urlAttributionPresenter,
                        urlProvider: urlProvider,
                        theme: theme
                    )
                }

                it("should return a correctly configured instance") {
                    let newsArticle = NewsArticle(title: "a", date: NSDate(), body: "a body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL())

                    let controller = subject.provideInstanceWithNewsFeedItem(newsArticle) as! NewsArticleController

                    expect(controller.newsArticle).to(beIdenticalTo(newsArticle))
                    expect(controller.imageService as? FakeImageService).to(beIdenticalTo(imageService))
                    expect(controller.timeIntervalFormatter as? FakeTimeIntervalFormatter).to(beIdenticalTo(timeIntervalFormatter))
                    expect(controller.analyticsService as? FakeAnalyticsService).to(beIdenticalTo(analyticsService))
                    expect(controller.urlOpener as? FakeURLOpener).to(beIdenticalTo(urlOpener))
                    expect(controller.urlAttributionPresenter as? FakeURLAttributionPresenter).to(beIdenticalTo(urlAttributionPresenter))
                    expect(controller.theme as? FakeTheme).to(beIdenticalTo(theme))
                }
            }

            describe("providing an instance with a video") {
                it("should return a correctly configured instance") {
                    let video = TestUtils.video()

                    let controller = subject.provideInstanceWithNewsFeedItem(video) as! VideoController

                    expect(controller.video).to(beIdenticalTo(video))
                    expect(controller.timeIntervalFormatter as? FakeTimeIntervalFormatter).to(beIdenticalTo(timeIntervalFormatter))
                    expect(controller.urlProvider as? FakeURLProvider).to(beIdenticalTo(urlProvider))
                    expect(controller.urlOpener as? FakeURLOpener).to(beIdenticalTo(urlOpener))
                    expect(controller.urlAttributionPresenter as? FakeURLAttributionPresenter).to(beIdenticalTo(urlAttributionPresenter))
                    expect(controller.analyticsService as? FakeAnalyticsService).to(beIdenticalTo(analyticsService))
                    expect(controller.theme as? FakeTheme).to(beIdenticalTo(theme))
                }
            }
        }
    }
}
