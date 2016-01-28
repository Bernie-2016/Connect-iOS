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

                let actionAlertB = actionAlerts[1]
                expect(actionAlertB.title).to(equal("Get out the vote!"))
            }

            context("when title is missing") {
                it("should not explode and ignore stories that lack them") {
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
