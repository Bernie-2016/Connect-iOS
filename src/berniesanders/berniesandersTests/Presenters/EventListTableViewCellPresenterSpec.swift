import berniesanders
import Quick
import Nimble

class EventListTableViewCellPresenterSpec : QuickSpec {
    var subject : EventListTableViewCellPresenter!

    override func spec() {
        describe("EventListTableViewCellPresenter") {
            beforeEach {
                self.subject = EventListTableViewCellPresenter()
            }
            
            describe("presenting an event") {
                var event : Event!
                var cell : EventListTableViewCell!
                
                beforeEach {
                    cell = EventListTableViewCell(style: .Default, reuseIdentifier: "fake-identifier")
                }
                
                context("when the event has a non-zero attendee capacity") {
                    beforeEach {
                        event = Event(name: "some event", attendeeCapacity: 10, attendeeCount: 2, city: "Bigtown", state: "CA", zip: "94104")
                        
                        self.subject.presentEvent(event, cell: cell)
                    }
                    
                    it("sets up the name label correctly") {
                        expect(cell.nameLabel.text).to(equal("some event"))
                    }
                    
                    it("sets up the address label correctly") {
                        expect(cell.addressLabel.text).to(equal("Bigtown, CA - 94104"))
                    }
                    
                    it("sets up the rsvp label correctly") {
                        expect(cell.attendeesLabel.text).to(equal("2 of RSVP: 10"))
                    }
                }
                
                context("when the event has a zero attendee capacity") {
                    beforeEach {
                        event = Event(name: "some event", attendeeCapacity: 0, attendeeCount: 2, city: "Bigtown", state: "CA", zip: "94104")
                        
                        self.subject.presentEvent(event, cell: cell)
                    }
                    
                    it("sets up the name label correctly") {
                        expect(cell.nameLabel.text).to(equal("some event"))
                    }
                    
                    it("sets up the address label correctly") {
                        expect(cell.addressLabel.text).to(equal("Bigtown, CA - 94104"))
                    }
                    
                    it("sets up the rsvp label correctly") {
                        expect(cell.attendeesLabel.text).to(equal("2 attending"))
                    }
                }
            }
        }
    }
}
