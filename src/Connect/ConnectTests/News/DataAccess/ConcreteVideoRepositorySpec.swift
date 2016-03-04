import Quick
import Nimble
import CBGPromise

@testable import Connect

class ConcreteVideoRepositorySpec : QuickSpec {
    override func spec() {
        describe("ConcreteVideoRepository") {
            var subject: ConcreteVideoRepository!
            let jsonClient = FakeJSONClient()
            let urlProvider = VideoRepositoryFakeURLProvider()
            let videoDeserializer = FakeVideoDeserializer()

            subject = ConcreteVideoRepository(
                urlProvider: urlProvider,
                jsonClient: jsonClient,
                videoDeserializer: videoDeserializer
            )

            describe(".fetchVideos") {
                var videosFuture: VideosFuture!

                beforeEach {
                    videosFuture = subject.fetchVideos()
                }

                it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                    expect(jsonClient.promisesByURL.count).to(equal(1))
                    expect(jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://youtube.com/bernese/")))

                    let expectedHTTPBodyDictionary =
                    [
                        "from": 0, "size": 5,
                        "_source": ["title", "video_id", "description", "timestamp_publish"],
                        "sort": [
                            "timestamp_publish": ["order": "desc", "ignore_unmapped": true]
                        ]
                    ]

                    expect(jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                    expect(jsonClient.lastMethod).to(equal("POST"))
                }

                context("when the request to the JSON client succeeds") {
                    let expectedJSONDictionary = NSDictionary();

                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.videoURL()]!

                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the video deserializer") {
                        expect(videoDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        let receivedVideos =  videosFuture.value!
                        expect(receivedVideos.count).to(equal(1))
                        expect(receivedVideos.first!.title).to(equal("Bernie MegaMix"))
                    }
                }

                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    it("calls the completion handler with an error") {
                        let promise = jsonClient.promisesByURL[urlProvider.videoURL()]!

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
                        let promise = jsonClient.promisesByURL[urlProvider.videoURL()]!
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

            describe("fetching a given video") {
                var videoFuture: VideoFuture!

                beforeEach {
                    videoFuture = subject.fetchVideo("some-identifier")
                }

                it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                    expect(jsonClient.promisesByURL.count).to(equal(1))
                    expect(jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://youtube.com/bernese/")))

                    let expectedHTTPBodyDictionary =
                    [
                        "from": 0, "size": 1,
                        "_source": ["title", "video_id", "description", "timestamp_publish"],
                        "filter": [
                            "term": [
                                "_id": "some-identifier",
                            ]
                        ]
                    ]

                    expect(jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                    expect(jsonClient.lastMethod).to(equal("POST"))
                }

                context("when the request to the JSON client succeeds with a video") {
                    let expectedJSONDictionary = NSDictionary();

                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.videoURL()]!

                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the video deserializer") {
                        expect(videoDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects") {
                        let receivedVideo =  videoFuture.value!
                        expect(receivedVideo.title).to(equal("Bernie MegaMix"))
                    }
                }

                context("when the request to the JSON client succeeds without a video") {
                    let expectedJSONDictionary = NSDictionary();

                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.videoURL()]!
                        videoDeserializer.returnedVideos = []
                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the video deserializer") {
                        expect(videoDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with an error") {
                        expect(videoFuture.error!) == VideoRepositoryError.NoMatchingVideo(identifier: "some-identifier")
                    }
                }


                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    it("calls the completion handler with an error") {
                        let promise = jsonClient.promisesByURL[urlProvider.videoURL()]!

                        let badObj = [1,2,3]
                        promise.resolve(badObj)

                        switch(videoFuture.error!) {
                        case VideoRepositoryError.InvalidJSON(let jsonObject):
                            expect(jsonObject as? [Int]).to(equal(badObj))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller") {
                        let promise = jsonClient.promisesByURL[urlProvider.videoURL()]!
                        let expectedUnderlyingError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        let jsonClientError = JSONClientError.NetworkError(error: expectedUnderlyingError)

                        promise.reject(jsonClientError)

                        switch(videoFuture.error!) {
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
    var returnedVideos = [TestUtils.video()]

    func deserializeVideos(jsonDictionary: NSDictionary) -> Array<Video> {
        lastReceivedJSONDictionary = jsonDictionary
        return returnedVideos
    }
}
