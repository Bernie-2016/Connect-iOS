import Foundation
import Quick
import Nimble
import berniesanders

public class ConcreteEventRSVPControllerProviderSpec : QuickSpec {
    var subject : ConcreteEventRSVPControllerProvider!
    let theme = FakeTheme()
    
    override public func spec() {
        describe("providing an instance with an event") {
            beforeEach {
                self.subject = ConcreteEventRSVPControllerProvider(
                    theme: self.theme
                )
            }
            
            it("should return a correctly configured instance") {
                let event = TestUtils.eventWithName("some event")
                
                let controller = self.subject.provideControllerWithEvent(event)
                
                expect(controller).to(beAnInstanceOf(EventRSVPController.self))
                expect(controller.event).to(beIdenticalTo(event))
                expect(controller.theme as? FakeTheme).to(beIdenticalTo(self.theme))
            }
        }
    }
}
