import UIKit
import Quick
import Nimble
import berniesanders

class EventFakeTheme : FakeTheme {
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }
    
    override func eventNameFont() -> UIFont {
        return UIFont.systemFontOfSize(111)
    }
    
    override func eventNameColor() -> UIColor {
        return UIColor.purpleColor()
    }
}

class EventControllerSpec: QuickSpec {
    var subject: EventController!
    let dateFormatter = NSDateFormatter()
    var eventPresenter : FakeEventPresenter!
    let theme = EventFakeTheme()
    let event = Event(name: "limited event", attendeeCapacity: 10, attendeeCount: 2, city: "San Francisco", state: "CA", zip: "94117")
    
    override func spec() {
        describe("EventController") {
            beforeEach {
                self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                self.dateFormatter.timeZone = NSTimeZone(name: "UTC")
                self.eventPresenter = FakeEventPresenter()
                self.subject = EventController(
                    event: self.event,
                    eventPresenter: self.eventPresenter,
                    dateFormatter: self.dateFormatter,
                    theme: self.theme)
                
                self.subject.view.layoutSubviews()
            }
            
            it("should hide the tab bar when pushed") {
                expect(self.subject.hidesBottomBarWhenPushed).to(beTrue())
            }
            
            it("has a scroll view containing the UI elements") {
                expect(self.subject.view.subviews.count).to(equal(1))
                var scrollView = self.subject.view.subviews.first as! UIScrollView
                
                expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                expect(scrollView.subviews.count).to(equal(1))
                
                var containerView = scrollView.subviews.first as! UIView
                
                expect(containerView.subviews.count).to(equal(6))
                
                var containerViewSubViews = containerView.subviews as! [UIView]
                
                expect(contains(containerViewSubViews, self.subject.nameLabel)).to(beTrue())
                expect(contains(containerViewSubViews, self.subject.dateLabel)).to(beTrue())
                expect(contains(containerViewSubViews, self.subject.attendeesLabel)).to(beTrue())
                expect(contains(containerViewSubViews, self.subject.addressLabel)).to(beTrue())
                expect(contains(containerViewSubViews, self.subject.descriptionHeadingLabel)).to(beTrue())
                expect(contains(containerViewSubViews, self.subject.descriptionLabel)).to(beTrue())
            }
            
            it("displays the title from the news item") {
                expect(self.subject.nameLabel.text).to(equal("limited event"))
            }
            
            it("uses the presenter to display the address") {
                expect(self.eventPresenter.lastEventWithPresentedAddress).to(beIdenticalTo(self.event))
                expect(self.subject.addressLabel.text).to(equal("SOME COOL ADDRESS!"))
            }
            
            it("uses the presenter to display the attendees") {
                expect(self.eventPresenter.lastEventWithPresentedAttendees).to(beIdenticalTo(self.event))
                expect(self.subject.attendeesLabel.text).to(equal("LOTS OF PEOPLE!"))
            }
            
            it("has a heading for the description") {
                expect(self.subject.descriptionHeadingLabel.text).to(equal("Description"))
            }
            
            xit("displays the event description") {
                expect(self.subject.descriptionLabel.text).to(equal("some description text we need to parse yet"))
            }
            
            it("styles the screen according to the theme") {
                expect(self.subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                expect(self.subject.nameLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                expect(self.subject.nameLabel.textColor).to(equal(UIColor.purpleColor()))
            }
        }
    }
}