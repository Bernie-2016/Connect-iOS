import Quick
import Nimble

@testable import Connect

class BackgroundVideoServiceSpec: QuickSpec {
    override func spec() {
        describe("BackgroundVideoService") {
            var subject: VideoService!
            var videoRepository: FakeVideoRepository!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!


            beforeEach {
                videoRepository = FakeVideoRepository()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = BackgroundVideoService(
                    videoRepository: videoRepository,
                    workerQueue: workerQueue,
                    resultQueue: resultQueue
                )
            }

            describe("fetching a particular video") {
                it("makes a request to the video repository on the worker queue") {
                    subject.fetchVideo("some-identifier")

                    expect(videoRepository.lastFetchedVideoIdentifier).to(beNil())

                    workerQueue.lastReceivedBlock()

                    expect(videoRepository.lastFetchedVideoIdentifier).to(equal("some-identifier"))
                }

                context("when the repository resolves its promise with a video") {
                    it("resolves its promise with the video on the result queue") {
                        let expectedVideo = TestUtils.video()

                        let future = subject.fetchVideo("some-identifier")
                        workerQueue.lastReceivedBlock()

                        videoRepository.lastVideoPromise.resolve(expectedVideo)

                        expect(future.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.value).to(beIdenticalTo(expectedVideo))
                    }
                }

                context("when the repository rejects its promise with an error") {
                    it("rejects its promise with the error on the result queue") {
                        let expectedError = VideoRepositoryError.NoMatchingVideo(identifier: "wat")

                        let future = subject.fetchVideo("some-identifier")
                        workerQueue.lastReceivedBlock()

                        videoRepository.lastVideoPromise.reject(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        switch(future.error!) {
                        case .NoMatchingVideo(let identifier):
                            expect(identifier).to(equal("wat"))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }
            }
        }
    }
}
