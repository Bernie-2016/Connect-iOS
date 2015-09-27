import berniesanders
import Quick
import Nimble

class EventPresenterSpec : QuickSpec {
    var subject : EventPresenter!

    override func spec() {
        fdescribe("EventPresenter") {
            var event : Event!
 
            beforeEach {
                event = Event(name: "some event", attendeeCapacity: 10, attendeeCount: 2, city: "Bigtown", state: "CA", zip: "94104")
                
                self.subject = EventPresenter()
            }
            
            describe("formatting an address") {
                it("correctly formats the address") {
                    expect(self.subject.presentAddressForEvent(event)).to(equal("Bigtown, CA - 94104"))
                }
            }
            
            describe("formatting attendance") {
                context("when the event has a non-zero attendee capacity") {
                    it("sets up the rsvp label correctly") {
                        expect(self.subject.presentAttendeesForEvent(event)).to(equal("2 of RSVP: 10"))
                    }
                }
                
                context("when the event has a zero attendee capacity") {
                    beforeEach {
                        event = Event(name: "some event", attendeeCapacity: 0, attendeeCount: 2, city: "Bigtown", state: "CA", zip: "94104")
                    }
                    
                    it("sets up the rsvp label correctly") {
                        expect(self.subject.presentAttendeesForEvent(event)).to(equal("2 attending"))
                    }
                }
            }
            
            describe("presenting an event in a table view cell") {
                var cell : EventListTableViewCell!
                
                beforeEach {
                    cell = EventListTableViewCell(style: .Default, reuseIdentifier: "fake-identifier")
                }
                
                context("when the event has a non-zero attendee capacity") {

                    beforeEach {
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
