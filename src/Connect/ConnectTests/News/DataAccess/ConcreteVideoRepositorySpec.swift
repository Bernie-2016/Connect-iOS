import Quick
import Nimble
import CBGPromise

@testable import Connect

class ConcreteVideoRepositorySpec : QuickSpec {
    var subject: ConcreteVideoRepository!
    let jsonClient = FakeJSONClient()
    private let urlProvider = VideoRepositoryFakeURLProvider()
    private let videoDeserializer = FakeVideoDeserializer()
    var receivedVideos: Array<Video>!
    var receivedError: NSError!

    override func spec() {
        describe("ConcreteVideoRepository") {
            self.subject = ConcreteVideoRepository(
                urlProvider: self.urlProvider,
                jsonClient: self.jsonClient,
                videoDeserializer: self.videoDeserializer
            )

            describe(".fetchVideos") {
                var videosFuture: VideosFuture!

                beforeEach {
                    videosFuture = self.subject.fetchVideos()
                }

                it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                    expect(self.jsonClient.promisesByURL.count).to(equal(1))
                    expect(self.jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://youtube.com/bernese/")))

                    let expectedHTTPBodyDictionary =
                    [
                        "from": 0, "size": 5,
                        "_source": ["title", "video_id", "description", "timestamp_publish"],
                        "sort": [
                            "timestamp_publish": ["order": "desc", "ignore_unmapped": true]
                        ]
                    ]

                    expect(self.jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                    expect(self.jsonClient.lastMethod).to(equal("POST"))
                }

                context("when the request to the JSON client succeeds") {
                    let expectedJSONDictionary = NSDictionary();

                    beforeEach {
                        let promise = self.jsonClient.promisesByURL[self.urlProvider.videoURL()]!

                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the video deserializer") {
                        expect(self.videoDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        let receivedVideos =  videosFuture.value!
                        expect(receivedVideos.count).to(equal(1))
                        expect(receivedVideos.first!.title).to(equal("Bernie MegaMix"))
                    }
                }

                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    it("calls the completion handler with an error") {
                        let promise = self.jsonClient.promisesByURL[self.urlProvider.videoURL()]!

                        let badObj = [1,2,3]
                        promise.resolve(badObj)

                        switch(videosFuture.error!) {
                        case VideoRepositoryError.InvalidJSON(let jsonObject):
                            expect(jsonObject as? [Int]).to(equal(badObj))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = self.jsonClient.promisesByURL[self.urlProvider.videoURL()]!
                        let expectedUnderlyingError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        let jsonClientError = JSONClientError.NetworkError(error: expectedUnderlyingError)

                        promise.reject(jsonClientError)

                        switch(videosFuture.error!) {
                        case VideoRepositoryError.ErrorInJSONClient(let jsonClientError):
                            switch(jsonClientError) {
                            case JSONClientError.NetworkError(let underlyingError):
                                expect(underlyingError).to(beIdenticalTo(expectedUnderlyingError))
                            default:
                                fail("unexpected error type")
                            }
                        default:
                               fail("unexpected error type")
                        }
                    }
                }
            }
        }
    }
}

private class VideoRepositoryFakeURLProvider: FakeURLProvider {
    override func videoURL() -> NSURL {
        return NSURL(string: "https://youtube.com/bernese/")!
    }
}

private class FakeVideoDeserializer: VideoDeserializer {
    var lastReceivedJSONDictionary: NSDictionary!
    let returnedVideos = [TestUtils.video()]

    func deserializeVideos(jsonDictionary: NSDictionary) -> Array<Video> {
        self.lastReceivedJSONDictionary = jsonDictionary
        return self.returnedVideos
    }
}
