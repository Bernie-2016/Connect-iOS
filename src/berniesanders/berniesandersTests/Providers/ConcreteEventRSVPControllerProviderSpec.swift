import Foundation
import Quick
import Nimble
import berniesanders

public class ConcreteEventRSVPControllerProviderSpec : QuickSpec {
    var subject : ConcreteEventRSVPControllerProvider!
    let analyticsService = FakeAnalyticsService()
    let theme = FakeTheme()

    override public func spec() {
        describe("providing an instance with an event") {
            beforeEach {
                self.subject = ConcreteEventRSVPControllerProvider(
                    analyticsService: self.analyticsService,
                    theme: self.theme
                )
            }

            it("should return a correctly configured instance") {
                let event = TestUtils.eventWithName("some event")

                let controller = self.subject.provideControllerWithEvent(event)

                expect(controller).to(beAnInstanceOf(EventRSVPController.self))
                expect(controller.analyticsService as? FakeAnalyticsService).to(beIdenticalTo(self.analyticsService))
                expect(controller.event).to(beIdenticalTo(event))
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}
