
import Quick
import Nimble

@testable import Connect

class StockActionAlertDeserializerSpec: QuickSpec {
    override func spec() {
        describe("StockActionAlertDeserializer") {
            var subject: ActionAlertDeserializer!

            beforeEach {
                subject = StockActionAlertDeserializer()
            }

            describe("deserializing an array of action alerts") {
                it("deserializes valid action alerts correctly") {
                    let data = TestUtils.dataFromFixtureFileNamed("action_alerts", type: "json")

                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()))

                    var actionAlerts = subject.deserializeActionAlerts(jsonDictionary as! Dictionary<String, AnyObject>)

                    expect(actionAlerts.count).to(equal(3))

                    let actionAlertA = actionAlerts[0]
                    expect(actionAlertA.identifier).to(equal("13"))
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

            describe("deserializing a single action alert") {
                var jsonDictionary: [String: AnyObject]!

                beforeEach {
                    let data = TestUtils.dataFromFixtureFileNamed("action_alert", type: "json")

                    jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! [String : AnyObject]
                }

                func removeAttribute(attribute: String, var jsonDictionaryToAlter: [String: AnyObject]) -> [String: AnyObject] {
                    var dataDictionary = jsonDictionaryToAlter["data"] as! [String: AnyObject]
                    var attributesDictionary = dataDictionary["attributes"] as! [String: AnyObject]
                    attributesDictionary.removeValueForKey(attribute)
                    dataDictionary["attributes"] = attributesDictionary
                    jsonDictionaryToAlter["data"] = dataDictionary
                    return jsonDictionaryToAlter
                }

                it("deserializes a valid action alert correctly") {
                    let actionAlert = try! subject.deserializeActionAlert(jsonDictionary)

                    expect(actionAlert.identifier) == "13"
                    expect(actionAlert.title) == "This is another alert"
                    expect(actionAlert.body) == "I wouldn't say I buy it Liz, let's just say I'm window shopping.\n\n\n\nAnd right now, there's a half price sale on '_weird_'"
                    expect(actionAlert.shortDescription) == "Monkeys were created by God to entertain us. That's all we know Rick."
                    expect(actionAlert.date) == "Thursday alert!"
                }

                describe("sharing URLs") {
                    var data: NSData!

                    beforeEach {
                        data = TestUtils.dataFromFixtureFileNamed("action_alert", type: "json")
                    }

                    it("includes the sharing URLs when present and valid") {
                        let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! [String: AnyObject]
                        let actionAlert = try! subject.deserializeActionAlert(jsonDictionary)

                        expect(actionAlert.targetURL).to(equal(NSURL(string: "https://www.youtube.com/watch?v=cr6ufGzlcwk")!))
                        expect(actionAlert.twitterURL).to(equal(NSURL(string: "https://www.youtube.com/watch?v=oNSPOYH510w")!))
                        expect(actionAlert.tweetID).to(equal("677935459260096513"))
                    }

                    it("converts empty string URLs to nil") {
                        var jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! [String: AnyObject]
                        var dataDictionary = jsonDictionary["data"] as! [String: AnyObject]
                        var attributesDictionary = dataDictionary["attributes"] as! [String: AnyObject]
                        attributesDictionary["target_url"] = ""
                        attributesDictionary["twitter_url"] = ""
                        attributesDictionary["tweet_id"] = ""
                        dataDictionary["attributes"] = attributesDictionary
                        jsonDictionary["data"] = dataDictionary

                        let actionAlert = try! subject.deserializeActionAlert(jsonDictionary)

                        expect(actionAlert.targetURL).to(beNil())
                        expect(actionAlert.twitterURL).to(beNil())
                        expect(actionAlert.tweetID).to(beNil())
                    }

                    it("includes allows nil sharing URLs") {
                        var jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [String: AnyObject])
                        jsonDictionary = removeAttribute("target_url", jsonDictionaryToAlter: jsonDictionary)
                        jsonDictionary = removeAttribute("twitter_url", jsonDictionaryToAlter: jsonDictionary)
                        jsonDictionary = removeAttribute("tweet_id", jsonDictionaryToAlter: jsonDictionary)
                        let actionAlert = try! subject.deserializeActionAlert(jsonDictionary)

                        expect(actionAlert.targetURL).to(beNil())
                        expect(actionAlert.twitterURL).to(beNil())
                        expect(actionAlert.tweetID).to(beNil())
                    }

                    it("converts invalid URLs to nil") {
                        var jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! [String: AnyObject]
                        var dataDictionary = jsonDictionary["data"] as! [String: AnyObject]
                        var attributesDictionary = dataDictionary["attributes"] as! [String: AnyObject]
                        attributesDictionary["target_url"] = "lkasdkfa/12#!@#"
                        attributesDictionary["twitter_url"] = "lkasdkfa/12#!@#"
                        attributesDictionary["tweet_id"] = [1,2,3]
                        dataDictionary["attributes"] = attributesDictionary
                        jsonDictionary["data"] = dataDictionary

                        let actionAlert = try! subject.deserializeActionAlert(jsonDictionary)

                        expect(actionAlert.targetURL).to(beNil())
                        expect(actionAlert.twitterURL).to(beNil())
                        expect(actionAlert.tweetID).to(beNil())
                    }
                }

                context("when the data attribute is missing") {
                    it("throws a missing attribute error") {
                        jsonDictionary.removeValueForKey("data")
                        expect{ try subject.deserializeActionAlert(jsonDictionary) }.to(throwError(ActionAlertDeserializerError.MissingAttribute("data")))
                    }
                }

                context("when attributes is missing") {
                    it("throws a missing attribute error") {
                        var dataDictionary = jsonDictionary["data"] as! [String: AnyObject]
                        dataDictionary.removeValueForKey("attributes")
                        jsonDictionary["data"] = dataDictionary
                        expect{ try subject.deserializeActionAlert(jsonDictionary) }.to(throwError(ActionAlertDeserializerError.MissingAttribute("attributes")))
                    }
                }

                it("throws a missing attribute error when id is missing") {
                    var dataDictionary = jsonDictionary["data"] as! [String: AnyObject]
                    dataDictionary.removeValueForKey("id")
                    jsonDictionary["data"] = dataDictionary

                    expect { try subject.deserializeActionAlert(jsonDictionary) }.to(throwError(ActionAlertDeserializerError.MissingAttribute("id")))
                }

                it("throws a missing attribute error when title is missing") {
                    let invalidJSONDictionary = removeAttribute("title", jsonDictionaryToAlter: jsonDictionary)

                    expect { try subject.deserializeActionAlert(invalidJSONDictionary) }.to(throwError(ActionAlertDeserializerError.MissingAttribute("title")))
                }


                it("throws a missing attribute error when body_html is missing") {
                    let invalidJSONDictionary = removeAttribute("body_html", jsonDictionaryToAlter: jsonDictionary)

                    expect { try subject.deserializeActionAlert(invalidJSONDictionary) }.to(throwError(ActionAlertDeserializerError.MissingAttribute("body_html")))
                }


                it("throws a missing attribute error when date is missing") {
                    let invalidJSONDictionary = removeAttribute("date", jsonDictionaryToAlter: jsonDictionary)

                    expect { try subject.deserializeActionAlert(invalidJSONDictionary) }.to(throwError(ActionAlertDeserializerError.MissingAttribute("date")))
                }

                it("throws a missing attribute error when short description is missing") {
                    let invalidJSONDictionary = removeAttribute("short_description", jsonDictionaryToAlter: jsonDictionary)

                    expect { try subject.deserializeActionAlert(invalidJSONDictionary) }.to(throwError(ActionAlertDeserializerError.MissingAttribute("short_description")))
                }
            }
        }
    }
}
