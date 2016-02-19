import Quick
import Nimble

@testable import Connect

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
                        let jsonDictionary = actionAlertDeserializer.lastReceivedActionAlertsJSONDictionary! as? Dictionary<String, String>
                        expect(jsonDictionary).to(equal(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        expect(actionAlertsFuture.value!.count).to(equal(1))
                        expect(actionAlertsFuture.value!.first!).to(equal(expectedActionAlerts.first!))
                    }
                }

                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
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
            describe("fetching a given action alert") {
                var actionAlertFuture: ActionAlertFuture!

                beforeEach {
                    actionAlertFuture = subject.fetchActionAlert("some-identifier")
                }

                it("makes a single request to the JSON Client with the correct URL from the provider and method") {
                    expect(urlProvider.lastReceivedIdentifier).to(equal("some-identifier"))
                    expect(jsonClient.promisesByURL.count).to(equal(1))
                    expect(jsonClient.promisesByURL.keys.first).to(beIdenticalTo(urlProvider.returnedActionAlertURL))

                    expect(jsonClient.lastBodyDictionary).to(beNil())
                    expect(jsonClient.lastMethod).to(equal("GET"))
                }

                context("when the request to the JSON client succeeds with an action alert") {
                    var expectedJSONDictionary: Dictionary<String, AnyObject>!

                    beforeEach {
                        expectedJSONDictionary = ["wat": "evs"]
                        let promise = jsonClient.promisesByURL[urlProvider.returnedActionAlertURL]!

                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the deserializer") {
                        let receivedDictionary = actionAlertDeserializer.lastReceivedActionAlertJSONDictionary as? [String:String]
                        expect(receivedDictionary).to(equal(expectedJSONDictionary as? [String:String]))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        let receivedActionAlert = actionAlertFuture.value!
                        expect(receivedActionAlert).to(equal(actionAlertDeserializer.returnedActionAlert))
                    }
                }

                context("when the request to the JSON client succeeds, but the action alert cannot be deserialized") {
                    var expectedJSONDictionary: Dictionary<String, AnyObject>!

                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.actionAlertURL("some-identifier")]!
                        actionAlertDeserializer.throwErrorWhenDeserializingActionAlert = true

                        expectedJSONDictionary = ["wat": "evs"]
                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the deserializer") {
                        let receivedDictionary = actionAlertDeserializer.lastReceivedActionAlertJSONDictionary as? [String:String]
                        expect(receivedDictionary).to(equal(expectedJSONDictionary as? [String:String]))
                    }

                    it("calls the completion handler with an error") {
                        let deserializerError = ActionAlertDeserializerError.InvalidJSON(expectedJSONDictionary)
                        let expectedError = ActionAlertRepositoryError.DeserializerError(deserializerError)
                        expect(actionAlertFuture.error!).to(equal(expectedError))
                    }
                }


                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    it("calls the completion handler with an error") {
                        let promise = jsonClient.promisesByURL[urlProvider.returnedActionAlertURL]!

                        let badObj = [1,2,3]
                        promise.resolve(badObj)

                        let expectedError = ActionAlertRepositoryError.InvalidJSON(jsonObject: badObj)
                        expect(actionAlertFuture.error!).to(equal(expectedError))
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = jsonClient.promisesByURL[urlProvider.returnedActionAlertURL]!
                        let expectedUnderlyingError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        let jsonClientError = JSONClientError.NetworkError(error: expectedUnderlyingError)

                        promise.reject(jsonClientError)
                        let expectedError = ActionAlertRepositoryError.ErrorInJSONClient(jsonClientError)

                        expect(actionAlertFuture.error!).to(equal(expectedError))
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

    var lastReceivedIdentifier: ActionAlertIdentifier!
    let returnedActionAlertURL = NSURL(string: "https://www.youtube.com/watch?v=MBS-KoaDDhA")!
    private override func actionAlertURL(identifier: ActionAlertIdentifier) -> NSURL {
        lastReceivedIdentifier = identifier
        return returnedActionAlertURL
    }
}

private class FakeActionAlertDeserializer: ActionAlertDeserializer {
    let returnedActionAlerts = [TestUtils.actionAlert()]
    var lastReceivedActionAlertsJSONDictionary: Dictionary<String, AnyObject>!

    private func deserializeActionAlerts(jsonDictionary: Dictionary<String, AnyObject>) -> [ActionAlert] {
        lastReceivedActionAlertsJSONDictionary = jsonDictionary
        return returnedActionAlerts
    }

    var throwErrorWhenDeserializingActionAlert = false
    var lastReceivedActionAlertJSONDictionary: Dictionary<String, AnyObject>!
    let returnedActionAlert = TestUtils.actionAlert()

    private func deserializeActionAlert(jsonDictionary: Dictionary<String, AnyObject>) throws -> ActionAlert {
        lastReceivedActionAlertJSONDictionary = jsonDictionary

        if throwErrorWhenDeserializingActionAlert {
            throw ActionAlertDeserializerError.InvalidJSON(jsonDictionary)
        }
        return returnedActionAlert
    }
}
