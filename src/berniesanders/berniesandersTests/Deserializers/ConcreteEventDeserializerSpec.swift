import Foundation
import Quick
import Nimble
import berniesanders
import CoreLocation

class ConcreteEventDeserializerSpec : QuickSpec {
    var subject: ConcreteEventDeserializer!
    
    override func spec() {
        beforeEach {
            self.subject = ConcreteEventDeserializer()
        }
        
        describe("ConcreteEventDeserializer") {
            it("deserializes the events correctly") {
                let data = TestUtils.dataFromFixtureFileNamed("events", type: "json")
                var error: NSError?
                
                let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                var events = self.subject.deserializeEvents(jsonDictionary)
                
                expect(events.count).to(equal(2))
                var eventA = events[0]
                expect(eventA.name).to(equal("Deputy Voter Registrar Training Class - Travis County"))
                expect(eventA.startDate).to(equal(NSDate(timeIntervalSince1970: 1446597000)))
                expect(eventA.timeZone).to(equal(NSTimeZone(abbreviation: "CST")))
                expect(eventA.attendeeCapacity).to(equal(10))
                expect(eventA.attendeeCount).to(equal(2))
                expect(eventA.streetAddress).to(equal("5501 Airport Blvd."))
                expect(eventA.city).to(equal("Austin"))
                expect(eventA.state).to(equal("TX"))
                expect(eventA.zip).to(equal("78746"))
                expect(eventA.location.coordinate.latitude).to(equal(30.31706))
                expect(eventA.location.coordinate.longitude).to(equal(-97.713631))
                expect(eventA.description).to(equal("Deputy Voter Registrar Training Class - Travis County\nCall (512) 854-9473 a year ahead to R.S.V.P."))
                expect(eventA.URL).to(equal(NSURL(string: "https://go.berniesanders.com/page/event/detail/registeringvoters/4vfdg")))
                
                var eventB = events[1]
                expect(eventB.name).to(equal("Deputy Dawg Training Class - Travis County"))
                expect(eventB.startDate).to(equal(NSDate(timeIntervalSince1970: 1465176600)))
                expect(eventB.timeZone).to(equal(NSTimeZone(abbreviation: "PST")))
                expect(eventB.attendeeCapacity).to(equal(11))
                expect(eventB.attendeeCount).to(equal(1))
                expect(eventB.streetAddress).to(beNil())
                expect(eventB.city).to(equal("Dallas"))
                expect(eventB.state).to(equal("TX"))
                expect(eventB.zip).to(equal("78747"))
                expect(eventB.location.coordinate.latitude).to(equal(31.31706))
                expect(eventB.location.coordinate.longitude).to(equal(-98.713631))
                expect(eventB.description).to(equal("Deputy Dawg Registrar Training Class - Travis County\nCall (512) 854-9473 a week ahead to R.S.V.P."))
                expect(eventB.URL).to(equal(NSURL(string: "https://go.berniesanders.com/page/event/detail/registeringvoters/4vfd4")))
            }
            
            context("when name, OTHER STUFF are missing") {
                it("should not explode and ignore stories that lack them") {
                    let data = TestUtils.dataFromFixtureFileNamed("dodgy_events", type: "json")
                    var error: NSError?
                    
                    let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                    var events = self.subject.deserializeEvents(jsonDictionary)
                    
                    expect(events.count).to(equal(1))
                    var event = events[0]
                    expect(event.name).to(equal("Deputy Dawg Training Class - Travis County"))
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
