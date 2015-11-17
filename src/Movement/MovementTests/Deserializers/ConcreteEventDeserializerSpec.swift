import Foundation
import Quick
import Nimble
@testable import Movement
import CoreLocation

class ConcreteEventDeserializerSpec : QuickSpec {
    var subject: ConcreteEventDeserializer!

    override func spec() {
        beforeEach {
            self.subject = ConcreteEventDeserializer(stringContentSanitizer: FakeStringContentSanitizer())
        }

        describe("ConcreteEventDeserializer") {
            it("deserializes the events correctly") {
                let data = TestUtils.dataFromFixtureFileNamed("events", type: "json")

                let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
                var events = self.subject.deserializeEvents(jsonDictionary)

                expect(events.count).to(equal(2))
                let eventA = events[0]
                expect(eventA.name).to(equal("Deputy Voter Registrar Training Class - Travis County SANITIZED!"))
                expect(eventA.startDate).to(equal(NSDate(timeIntervalSince1970: 1446597000)))
                expect(eventA.timeZone).to(equal(NSTimeZone(abbreviation: "CST")))
                expect(eventA.attendeeCapacity).to(equal(10))
                expect(eventA.attendeeCount).to(equal(2))
                expect(eventA.streetAddress).to(equal("5501 Airport Blvd. SANITIZED!"))
                expect(eventA.city).to(equal("Austin SANITIZED!"))
                expect(eventA.state).to(equal("TX SANITIZED!"))
                expect(eventA.zip).to(equal("78746"))
                expect(eventA.location.coordinate.latitude).to(equal(30.31706))
                expect(eventA.location.coordinate.longitude).to(equal(-97.713631))
                expect(eventA.description).to(equal("Deputy Voter Registrar Training Class - Travis County\nCall (512) 854-9473 a year ahead to R.S.V.P. SANITIZED!"))
                expect(eventA.url).to(equal(NSURL(string: "https://go.berniesanders.com/page/event/detail/registeringvoters/4vfdg")))
                expect(eventA.eventTypeName).to(equal("Bernie Party SANITIZED!"))

                let eventB = events[1]
                expect(eventB.name).to(equal("Deputy Dawg Training Class - Travis County SANITIZED!"))
                expect(eventB.startDate).to(equal(NSDate(timeIntervalSince1970: 1465176600)))
                expect(eventB.timeZone).to(equal(NSTimeZone(abbreviation: "PST")))
                expect(eventB.attendeeCapacity).to(equal(11))
                expect(eventB.attendeeCount).to(equal(1))
                expect(eventB.streetAddress).to(beNil())
                expect(eventB.city).to(equal("Dallas SANITIZED!"))
                expect(eventB.state).to(equal("TX SANITIZED!"))
                expect(eventB.zip).to(equal("78747"))
                expect(eventB.location.coordinate.latitude).to(equal(31.31706))
                expect(eventB.location.coordinate.longitude).to(equal(-98.713631))
                expect(eventB.description).to(equal("Deputy Dawg Registrar Training Class - Travis County\nCall (512) 854-9473 a week ahead to R.S.V.P. SANITIZED!"))
                expect(eventB.url).to(equal(NSURL(string: "https://go.berniesanders.com/page/event/detail/registeringvoters/4vfd4")))
                expect(eventB.eventTypeName).to(beNil())
            }

            context("when name, OTHER STUFF are missing") {
                it("should not explode and ignore stories that lack them") {
                    let data = TestUtils.dataFromFixtureFileNamed("dodgy_events", type: "json")
                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
                    var events = self.subject.deserializeEvents(jsonDictionary)

                    expect(events.count).to(equal(1))
                    let event = events[0]
                    expect(event.name).to(equal("Deputy Dawg Training Class - Travis County SANITIZED!"))
                }
            }

            context("when there's not enough hits") {
                it("should not explode") {
                    var events = self.subject.deserializeEvents([String: AnyObject]())
                    expect(events.count).to(equal(0))

                    events = self.subject.deserializeEvents(["hits": [String: AnyObject]()])
                    expect(events.count).to(equal(0))

                    events = self.subject.deserializeEvents(["hits": [ "hits": [String: AnyObject]()]])
                    expect(events.count).to(equal(0));
                }
            }
        }
    }
}
