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

                expect(actionAlerts.count).to(equal(3))

                let actionAlertA = actionAlerts[0]
                expect(actionAlertA.title).to(equal("This is another alert"))
                expect(actionAlertA.body).to(equal("I wouldn't say I buy it Liz, let's just say I'm window shopping.\n\n\n\nAnd right now, there's a half price sale on '_weird_'"))
                expect(actionAlertA.date).to(equal("Thursday alert!"))
            }

            describe("sharing URLs") {
                it("includes the sharing URLs when present and valid") {
                    let data = TestUtils.dataFromFixtureFileNamed("action_alerts", type: "json")

                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()))
                    var actionAlerts = subject.deserializeActionAlerts(jsonDictionary as! Dictionary<String, AnyObject>)
                    let actionAlert = actionAlerts[0]

                    expect(actionAlert.targetURL).to(equal(NSURL(string: "https://www.youtube.com/watch?v=cr6ufGzlcwk")!))
                    expect(actionAlert.twitterURL).to(equal(NSURL(string: "https://www.youtube.com/watch?v=oNSPOYH510w")!))
                    expect(actionAlert.tweetID).to(equal("677935459260096513"))
                }

                it("converts empty string URLs to nil") {
                    let data = TestUtils.dataFromFixtureFileNamed("action_alerts", type: "json")

                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()))
                    var actionAlerts = subject.deserializeActionAlerts(jsonDictionary as! Dictionary<String, AnyObject>)
                    let actionAlert = actionAlerts[1]

                    expect(actionAlert.targetURL).to(beNil())
                    expect(actionAlert.twitterURL).to(beNil())
                    expect(actionAlert.tweetID).to(beNil())
                }

                it("includes allows nil sharing URLs") {
                    let data = TestUtils.dataFromFixtureFileNamed("action_alerts", type: "json")

                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()))
                    var actionAlerts = subject.deserializeActionAlerts(jsonDictionary as! Dictionary<String, AnyObject>)
                    let actionAlert = actionAlerts[2]

                    expect(actionAlert.targetURL).to(beNil())
                    expect(actionAlert.twitterURL).to(beNil())
                    expect(actionAlert.tweetID).to(beNil())
                }

                it("converts invalid URLs to nil") {
                    let data = TestUtils.dataFromFixtureFileNamed("action_alert_with_invalid_sharing_urls", type: "json")
                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! Dictionary<String, AnyObject>

                    var actionAlerts = subject.deserializeActionAlerts(jsonDictionary)
                    expect(actionAlerts.count).to(equal(1))

                    let actionAlert = actionAlerts[0]
                    expect(actionAlert.title).to(equal("This is an alert with bad sharing URLs"))
                    expect(actionAlert.targetURL).to(beNil())
                    expect(actionAlert.twitterURL).to(beNil())
                    expect(actionAlert.tweetID).to(beNil())
                }
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
