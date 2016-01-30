import Quick
import Nimble

@testable import Movement

class StockActionAlertDeserializerSpec: QuickSpec {
    override func spec() {
        describe("StockActionAlertDeserializer") {
            var subject: ActionAlertDeserializer!

            beforeEach {
                subject = StockActionAlertDeserializer()
            }

            it("deserializes the issues correctly") {
                let data = TestUtils.dataFromFixtureFileNamed("action_alerts", type: "json")

                let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()))

                var actionAlerts = subject.deserializeActionAlerts(jsonDictionary as! Dictionary<String, AnyObject>)

                expect(actionAlerts.count).to(equal(2))

                let actionAlertA = actionAlerts[0]
                expect(actionAlertA.title).to(equal("This is another alert"))
                expect(actionAlertA.body).to(equal("I wouldn't say I buy it Liz, let's just say I'm window shopping.\n\n\n\nAnd right now, there's a half price sale on '_weird_'"))
                expect(actionAlertA.date).to(equal("Thursday alert!"))

                let actionAlertB = actionAlerts[1]
                expect(actionAlertB.title).to(equal("Get out the vote!"))
                expect(actionAlertB.body).to(equal("Vote Bernie 2016"))
                expect(actionAlertB.date).to(equal("This Minute"))
            }

            context("when content is missing") {
                it("should not explode and ignore action alerts that lack required content") {
                    let data = TestUtils.dataFromFixtureFileNamed("dodgy_action_alerts", type: "json")

                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()))
                    var actionAlerts = subject.deserializeActionAlerts(jsonDictionary as! Dictionary<String, AnyObject>)

                    expect(actionAlerts.count).to(equal(1))
                    let actionAlert = actionAlerts[0]
                    expect(actionAlert.title).to(equal("This is a valid action alert"))
                }

            }
            context("when the response is generally not well formed") {
                it("should not explode") {
                    var actionAlerts = subject.deserializeActionAlerts([String: AnyObject]())
                    expect(actionAlerts.count).to(equal(0))

                    actionAlerts = subject.deserializeActionAlerts(["data": [String: AnyObject]()])
                    expect(actionAlerts.count).to(equal(0))
                }
            }
        }
    }
}
