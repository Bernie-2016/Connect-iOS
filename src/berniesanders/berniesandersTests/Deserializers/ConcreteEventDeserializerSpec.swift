import Foundation
import Quick
import Nimble
import berniesanders

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
                expect(eventA.attendeeCapacity).to(equal(10))
                expect(eventA.attendeeCount).to(equal(2))
                expect(eventA.city).to(equal("Austin"))
                expect(eventA.state).to(equal("TX"))
                expect(eventA.zip).to(equal("78746"))
                
                var eventB = events[1]
                expect(eventB.name).to(equal("Deputy Dawg Training Class - Travis County"))
                expect(eventB.attendeeCapacity).to(equal(11))
                expect(eventB.attendeeCount).to(equal(1))
                expect(eventB.city).to(equal("Dallas"))
                expect(eventB.state).to(equal("TX"))
                expect(eventB.zip).to(equal("78747"))
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
