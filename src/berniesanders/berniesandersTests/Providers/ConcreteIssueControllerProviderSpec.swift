import Foundation
import Quick
import Nimble
@testable import berniesanders

class ConcreteIssueControllerProviderSpec : QuickSpec {
    var subject : ConcreteIssueControllerProvider!
    let imageRepository = FakeImageRepository()
    let analyticsService = FakeAnalyticsService()
    let urlOpener = FakeURLOpener()
    let urlAttributionPresenter = FakeURLAttributionPresenter()
    let theme = FakeTheme()

    override func spec() {

        describe("providing an instance with an issue") {
            beforeEach {
                self.subject = ConcreteIssueControllerProvider(
                    imageRepository: self.imageRepository,
                    analyticsService: self.analyticsService,
                    urlOpener: self.urlOpener,
                    urlAttributionPresenter: self.urlAttributionPresenter,
                    theme: self.theme
                )
            }

            it("should return a correctly configured instance") {
                let issue = TestUtils.issue()

                let controller = self.subject.provideInstanceWithIssue(issue)

                expect(controller).to(beAnInstanceOf(IssueController.self))
                expect(controller.issue).to(beIdenticalTo(issue))
                expect(controller.imageRepository as? FakeImageRepository).to(beIdenticalTo(self.imageRepository))
                expect(controller.analyticsService as? FakeAnalyticsService).to(beIdenticalTo(self.analyticsService))
                expect(controller.urlOpener as? FakeURLOpener).to(beIdenticalTo(self.urlOpener))
                expect(controller.urlAttributionPresenter as? FakeURLAttributionPresenter).to(beIdenticalTo(self.urlAttributionPresenter))
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}
