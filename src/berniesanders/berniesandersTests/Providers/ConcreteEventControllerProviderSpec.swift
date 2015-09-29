import Foundation
import Quick
import Nimble
import berniesanders

public class ConcreteEventControllerProviderSpec : QuickSpec {
    var subject : ConcreteEventControllerProvider!
    let dateFormatter = NSDateFormatter()
    let theme = FakeTheme()
    let eventPresenter = EventPresenter(dateFormatter: FakeDateFormatter())
    let urlProvider = FakeURLProvider()
    let urlOpener = FakeURLOpener()
    
    override public func spec() {
        describe("providing an instance with an event") {
            beforeEach {
                self.subject = ConcreteEventControllerProvider(
                    eventPresenter: self.eventPresenter,
                    urlProvider: self.urlProvider,
                    urlOpener: self.urlOpener,
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
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}
