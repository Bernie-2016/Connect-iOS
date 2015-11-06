@testable import berniesanders
import Quick
import Nimble
import CoreLocation

class EventPresenterSpec : QuickSpec {
    var subject : EventPresenter!
    var sameTimeZoneDateFormatter : FakeDateFormatter!
    var differentTimeZoneDateFormatter : FakeDateFormatter!

    override func spec() {
        describe("EventPresenter") {
            var event : Event!

            beforeEach {
                self.sameTimeZoneDateFormatter = FakeDateFormatter()
                self.differentTimeZoneDateFormatter = FakeDateFormatter()

                let eventLocation = CLLocation(latitude: 37.7955745, longitude: -122.3955095)

                event = Event(name: "some event", startDate: NSDate(timeIntervalSince1970: 1433565000), timeZone: NSTimeZone.localTimeZone(),
                    attendeeCapacity: 10, attendeeCount: 2,
                    streetAddress: "100 Main Street", city: "Bigtown", state: "CA", zip: "94104", location: eventLocation,
                    description: "Words about the event", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")

                self.subject = EventPresenter(
                    sameTimeZoneDateFormatter: self.sameTimeZoneDateFormatter,
                    differentTimeZoneDateFormatter: self.differentTimeZoneDateFormatter
                )
            }

            describe("formatting an address") {
                context("when the address has a street address") {
                    it("correctly formats the address") {
                        expect(self.subject.presentAddressForEvent(event)).to(equal("100 Main Street\nBigtown, CA - 94104"))
                    }
                }

                context("when the address lacks a street address") {
                    beforeEach {
                        event = Event(name: "some event", startDate: NSDate(timeIntervalSince1970: 1433565000), timeZone: NSTimeZone(abbreviation: "PST")!,
                            attendeeCapacity: 10, attendeeCount: 2,
                            streetAddress: nil, city: "Bigtown", state: "CA", zip: "94104", location: CLLocation(),
                            description: "Words about the event", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")
                    }
                    it("correctly formats the address") {
                        expect(self.subject.presentAddressForEvent(event)).to(equal("Bigtown, CA - 94104"))
                    }
                }
            }

            describe("formatting attendance") {
                context("when the event has a non-zero attendee capacity") {
                    it("sets up the rsvp label correctly") {
                        expect(self.subject.presentAttendeesForEvent(event)).to(equal("2 attending, 10 spots total"))
                    }
                }

                context("when the event has a zero attendee capacity") {
                    beforeEach {
                        event = Event(name: "some event", startDate: NSDate(timeIntervalSince1970: 1433565000), timeZone: NSTimeZone(abbreviation: "PST")!,
                            attendeeCapacity: 0, attendeeCount: 2,
                            streetAddress: "100 Main Street", city: "Bigtown", state: "CA", zip: "94104", location: CLLocation(),
                            description: "Words about the event", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")
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
                    let searchCentroid = CLLocation(latitude: 37.8271868, longitude: -122.4240794)
                    self.subject.presentEvent(event, searchCentroid: searchCentroid, cell: cell)
                }

                it("sets up the name label correctly") {
                    expect(cell.nameLabel.text).to(equal("some event"))
                }

                it("displays the distance label using the passed in search centroid") {
                    expect(cell.distanceLabel.text).to(equal("2.7 mi"))
                }

                it("displays the date using the date formatter") {
                    expect(cell.dateLabel.text).to(equal("This is the date!"))
                    expect(self.sameTimeZoneDateFormatter.timeZone).to(equal(event.timeZone))
                    expect(self.sameTimeZoneDateFormatter.lastReceivedDate).to(equal(event.startDate))
                }
            }

            describe("formatting a start date") {
                context("when the event is in the user's time zone") {
                    it("uses the configured same-timezone date formatter") {
                        event = Event(name: "some event", startDate: NSDate(timeIntervalSince1970: 1433565000), timeZone: NSTimeZone.localTimeZone(),
                            attendeeCapacity: 10, attendeeCount: 2,
                            streetAddress: nil, city: "Bigtown", state: "CA", zip: "94104", location: CLLocation(),
                            description: "Words about the event", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")

                        expect(self.subject.presentDateForEvent(event)).to(equal("This is the date!"))
                        expect(self.sameTimeZoneDateFormatter.timeZone).to(equal(event.timeZone))
                        expect(self.sameTimeZoneDateFormatter.lastReceivedDate).to(beIdenticalTo(event.startDate))
                    }
                }

                context("when the event is in the user's time zone") {
                    it("uses the configured different-timezone date formatter") {
                        event = Event(name: "some event", startDate: NSDate(timeIntervalSince1970: 1433565000), timeZone: NSTimeZone(abbreviation: "UTC")!,
                            attendeeCapacity: 10, attendeeCount: 2,
                            streetAddress: nil, city: "Bigtown", state: "CA", zip: "94104", location: CLLocation(),
                            description: "Words about the event", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")

                        expect(self.subject.presentDateForEvent(event)).to(equal("This is the date!"))
                        expect(self.differentTimeZoneDateFormatter.timeZone).to(beIdenticalTo(event.timeZone))
                        expect(self.differentTimeZoneDateFormatter.lastReceivedDate).to(beIdenticalTo(event.startDate))
                    }
                }
            }
        }
    }
}
