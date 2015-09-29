import Foundation
import Quick
import Nimble
import berniesanders
import CoreLocation

class ConcreteURLProviderSpec : QuickSpec {
    var subject : ConcreteURLProvider!

    override func spec() {
        describe("ConcreteURLProvider") {
            beforeEach {
                self.subject = ConcreteURLProvider()
            }
            
            describe("building a maps URL for an event") {
                var event: Event!
                
                context("with an event with a street address") {
                    beforeEach {
                        let location = CLLocation(latitude: 0, longitude: 0)
                        event = Event(name: "name", startDate: NSDate(), timeZone: NSTimeZone(abbreviation: "PST")!, attendeeCapacity: 2, attendeeCount: 2, streetAddress: "1 Big Avenue", city: "Petaluma", state: "CA", zip: "11111", location: location, description: "desc", URL: NSURL(string: "https://example.com")!)
                    }
                    
                    it("builds the correct URL") {
                        expect(self.subject.mapsURLForEvent(event)).to(equal(NSURL(string: "https://maps.apple.com/?address=1%20Big%20Avenue,Petaluma,CA,11111")))
                    }
                }
                
                context("with an event that lacks a street address") {
                    beforeEach {
                        let location = CLLocation(latitude: 0, longitude: 0)
                        event = Event(name: "name", startDate: NSDate(), timeZone: NSTimeZone(abbreviation: "PST")!, attendeeCapacity: 2, attendeeCount: 2, streetAddress: nil, city: "Santa Rosa", state: "WA", zip: "22222", location: location, description: "desc", URL: NSURL(string: "https://example.com")!)
                    }

                    it("builds the correct URL") {
                        expect(self.subject.mapsURLForEvent(event)).to(equal(NSURL(string: "https://maps.apple.com/?address=Santa%20Rosa,WA,22222")))
                    }
                }
            }
        }
    }
}
