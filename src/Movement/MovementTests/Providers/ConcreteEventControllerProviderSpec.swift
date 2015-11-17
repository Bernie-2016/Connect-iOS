import Foundation
import Quick
import Nimble
@testable import Movement

class ConcreteEventControllerProviderSpec : QuickSpec {
    var subject : ConcreteEventControllerProvider!
    let dateFormatter = NSDateFormatter()
    let theme = FakeTheme()
    let eventPresenter = EventPresenter(                    sameTimeZoneDateFormatter: FakeDateFormatter(),
        differentTimeZoneDateFormatter: FakeDateFormatter(),
        sameTimeZoneFullDateFormatter: FakeDateFormatter(),
        differentTimeZoneFullDateFormatter: FakeDateFormatter())
    let eventRSVPControllerProvider = FakeEventRSVPControllerProvider()
    let urlProvider = FakeURLProvider()
    let urlOpener = FakeURLOpener()
    let analyticsService = FakeAnalyticsService()

    override func spec() {
        describe("providing an instance with an event") {
            beforeEach {
                self.subject = ConcreteEventControllerProvider(
                    eventPresenter: self.eventPresenter,
                    eventRSVPControllerProvider: self.eventRSVPControllerProvider,
                    urlProvider: self.urlProvider,
                    urlOpener: self.urlOpener,
                    analyticsService: self.analyticsService,
                    theme: self.theme
                )
            }

            it("should return a correctly configured instance") {
                let event = TestUtils.eventWithName("some event")

                let controller = self.subject.provideInstanceWithEvent(event)

                expect(controller).to(beAnInstanceOf(EventController.self))
                expect(controller.event).to(beIdenticalTo(event))
                expect(controller.eventPresenter).to(beIdenticalTo(self.eventPresenter))
                expect(controller.urlProvider as? FakeURLProvider).to(beIdenticalTo(self.urlProvider))
                expect(controller.urlOpener).to(beIdenticalTo(self.urlOpener))
                expect(controller.analyticsService as? FakeAnalyticsService).to(beIdenticalTo(self.analyticsService))
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}
