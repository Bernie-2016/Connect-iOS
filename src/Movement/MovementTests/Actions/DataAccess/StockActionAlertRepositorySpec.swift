import Quick
import Nimble

@testable import Movement

class StockActionAlertRepositoySpec: QuickSpec {
    override func spec() {
        describe("StockActionAlertRepository") {
            var subject: ActionAlertRepository!
            var jsonClient: FakeJSONClient!
            var actionAlertDeserializer: FakeActionAlertDeserializer!
            let urlProvider = ActionAlertFakeURLProvider()

            beforeEach {
                jsonClient = FakeJSONClient()
                actionAlertDeserializer = FakeActionAlertDeserializer()

                subject = StockActionAlertRepository(
                    jsonClient: jsonClient,
                    actionAlertDeserializer: actionAlertDeserializer,
                    urlProvider: urlProvider
                )
            }

            describe("fetching action alerts") {
                var actionAlertsFuture: ActionAlertsFuture!

                beforeEach {
                    actionAlertsFuture = subject.fetchActionAlerts()
                }

                it("makes a single request to the JSON Client with the correct URL and method") {
                    expect(jsonClient.promisesByURL.count).to(equal(1))
                    expect(jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://example.com/actionjackson")))
                    expect(jsonClient.lastMethod).to(equal("GET"))
                }

                context("when the request to the JSON client succeeds") {
                    let expectedJSONDictionary = ["lol": "lolle"]
                    var expectedActionAlerts: [ActionAlert]!

                    beforeEach {
                        expectedActionAlerts = actionAlertDeserializer.returnedActionAlerts
                        let jsonPromise = jsonClient.promisesByURL[urlProvider.actionAlertsURL()]!

                        jsonPromise.resolve(expectedJSONDictionary)
                    }

                    it("passes the JSON document to the action alert deserializer") {
                        let jsonDictionary = actionAlertDeserializer.lastReceivedJSONDictionary! as? Dictionary<String, String>
                        expect(jsonDictionary).to(equal(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        expect(actionAlertsFuture.value!.count).to(equal(1))
                        expect(actionAlertsFuture.value!.first!).to(equal(expectedActionAlerts.first!))
                    }
                }

                context("when he request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    it("calls the completion handler with an error") {
                        let jsonPromise = jsonClient.promisesByURL[urlProvider.actionAlertsURL()]!

                        let badObj = [1,2,3]
                        jsonPromise.resolve(badObj)

                        expect(actionAlertsFuture.error!).to(equal(ActionAlertRepositoryError.InvalidJSON(jsonObject: badObj)))

                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = jsonClient.promisesByURL[urlProvider.actionAlertsURL()]!
                        let expectedUnderlyingError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        let jsonClientError = JSONClientError.NetworkError(error: expectedUnderlyingError)

                        promise.reject(jsonClientError)

                        expect(actionAlertsFuture.error!).to(equal(ActionAlertRepositoryError.ErrorInJSONClient(jsonClientError)))
                    }
                }
            }
        }
    }
}

private class ActionAlertFakeURLProvider: FakeURLProvider {
    private override func actionAlertsURL() -> NSURL {
        return NSURL(string: "https://example.com/actionjackson")!
    }
}

private class FakeActionAlertDeserializer: ActionAlertDeserializer {
    let returnedActionAlerts = [TestUtils.actionAlert()]
    var lastReceivedJSONDictionary: Dictionary<String, AnyObject>!

    private func deserializeActionAlerts(jsonDictionary: Dictionary<String, AnyObject>) -> [ActionAlert] {
        lastReceivedJSONDictionary = jsonDictionary
        return returnedActionAlerts
    }
}
