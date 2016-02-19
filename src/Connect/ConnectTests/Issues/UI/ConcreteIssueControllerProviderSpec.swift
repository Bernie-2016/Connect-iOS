import Foundation
import Quick
import Nimble
@testable import Connect

class ConcreteIssueControllerProviderSpec : QuickSpec {
    override func spec() {
        describe("ConcreteIssueControllerProvider") {
            var subject: ConcreteIssueControllerProvider!
            let imageService = FakeImageService()
            let analyticsService = FakeAnalyticsService()
            let urlOpener = FakeURLOpener()
            let urlAttributionPresenter = FakeURLAttributionPresenter()
            let theme = FakeTheme()

            describe("providing an instance with an issue") {
                beforeEach {
                    subject = ConcreteIssueControllerProvider(
                        imageService: imageService,
                        analyticsService: analyticsService,
                        urlOpener: urlOpener,
                        urlAttributionPresenter: urlAttributionPresenter,
                        theme: theme
                    )
                }

                it("should return a correctly configured instance") {
                    let issue = TestUtils.issue()
                    let controller = subject.provideInstanceWithIssue(issue)

                    expect(controller).to(beAnInstanceOf(IssueController.self))
                    expect(controller.issue).to(beIdenticalTo(issue))
                    expect(controller.imageService as? FakeImageService).to(beIdenticalTo(imageService))
                    expect(controller.analyticsService as? FakeAnalyticsService).to(beIdenticalTo(analyticsService))
                    expect(controller.urlOpener as? FakeURLOpener).to(beIdenticalTo(urlOpener))
                    expect(controller.urlAttributionPresenter as? FakeURLAttributionPresenter).to(beIdenticalTo(urlAttributionPresenter))
                    expect(controller.theme as? FakeTheme).to(beIdenticalTo(theme))
                }
            }
        }
    }
}
