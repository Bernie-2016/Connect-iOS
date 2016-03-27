import Quick
import Nimble

@testable import Connect

class StockVersionRepositoySpec: QuickSpec {
    override func spec() {
        describe("StockVersionRepository") {
            var subject: VersionRepository!
            var jsonClient: FakeJSONClient!
            var versionDeserializer: FakeVersionDeserializer!
            let urlProvider = VersionFakeURLProvider()

            beforeEach {
                jsonClient = FakeJSONClient()
                versionDeserializer = FakeVersionDeserializer()

                subject = StockVersionRepository(
                    jsonClient: jsonClient,
                    versionDeserializer: versionDeserializer,
                    urlProvider: urlProvider
                )
            }

            describe("fetching the current version") {
                var versionFuture: VersionFuture!

                beforeEach {
                    versionFuture = subject.fetchCurrentVersion()
                }

                it("makes a single request to the JSON Client with the correct URL and method") {
                    expect(jsonClient.promisesByURL.count).to(equal(1))
                    expect(jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://example.com/version")))
                    expect(jsonClient.lastMethod).to(equal("GET"))
                }

                context("when the request to the JSON client succeeds") {
                    let expectedJSONDictionary = ["lol": "lolle"]
                    var expectedVersion: Version!

                    beforeEach {
                        expectedVersion = versionDeserializer.returnedVersion
                        let jsonPromise = jsonClient.promisesByURL[urlProvider.versionURL()]!

                        jsonPromise.resolve(expectedJSONDictionary)
                    }

                    it("passes the JSON document to the action alert deserializer") {
                        let jsonDictionary = versionDeserializer.lastReceivedVersionJSON! as? Dictionary<String, String>
                        expect(jsonDictionary) == expectedJSONDictionary
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        expect(versionFuture.value!) == expectedVersion
                    }
                }

                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    it("calls the completion handler with an error") {
                        let jsonPromise = jsonClient.promisesByURL[urlProvider.versionURL()]!

                        let badObj = [1,2,3]
                        jsonPromise.resolve(badObj)

                        expect(versionFuture.error!) == VersionRepositoryError.InvalidJSON(jsonObject: badObj)
                    }
                }

                context("when the request to the JSON client succeeds, but the version cannot be deserialized") {
                    var expectedJSONDictionary: Dictionary<String, AnyObject>!

                    beforeEach {
                        let jsonPromise = jsonClient.promisesByURL[urlProvider.versionURL()]!
                        versionDeserializer.throwErrorWhenDeserializing = true

                        expectedJSONDictionary = ["wat": "evs"]
                        jsonPromise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the deserializer") {
                        let receivedDictionary = versionDeserializer.lastReceivedVersionJSON as? [String:String]

                        expect(receivedDictionary).to(equal(expectedJSONDictionary as? [String:String]))
                    }

                    it("calls the completion handler with an error") {
                        let deserializerError = VersionDeserializerError.MissingAttribute("birdie sanders")
                        let expectedError = VersionRepositoryError.DeserializerError(deserializerError)

                        expect(versionFuture.error!).to(equal(expectedError))
                    }
                }


                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = jsonClient.promisesByURL[urlProvider.versionURL()]!
                        let expectedUnderlyingError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        let jsonClientError = JSONClientError.NetworkError(error: expectedUnderlyingError)

                        promise.reject(jsonClientError)

                        expect(versionFuture.error!) == VersionRepositoryError.ErrorInJSONClient(jsonClientError)
                    }
                }
            }
        }
    }
}

private class VersionFakeURLProvider: FakeURLProvider {
    private override func versionURL() -> NSURL {
        return NSURL(string: "https://example.com/version")!
    }
}

private class FakeVersionDeserializer: VersionDeserializer {
    let returnedVersion = Version(minimumVersion: 42, updateURL: NSURL(string: "https://example.com/update")!)
    var lastReceivedVersionJSON: Dictionary<String, AnyObject>?
    var throwErrorWhenDeserializing = false

    private func deserializeVersion(jsonDictionary: Dictionary<String, AnyObject>) throws -> Version {
        lastReceivedVersionJSON = jsonDictionary

        if throwErrorWhenDeserializing {
            throw VersionDeserializerError.MissingAttribute("birdie sanders")
        }
        return returnedVersion
    }
}
