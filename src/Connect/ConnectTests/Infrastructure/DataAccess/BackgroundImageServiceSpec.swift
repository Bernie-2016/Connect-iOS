import Quick
import Nimble

@testable import Connect

class BackgroundImageServiceSpec: QuickSpec {
    override func spec() {
        describe("BackgroundImageService") {
            var subject: ImageService!
            var imageRepository: FakeImageRepository!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!


            beforeEach {
                imageRepository = FakeImageRepository()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = BackgroundImageService(imageRepository: imageRepository, workerQueue: workerQueue, resultQueue: resultQueue)
            }

            describe("fetching events") {
                let expectedURL = NSURL(string: "https://i.imgur.com/FNEGGtv.jpg")!

                it("makes a request to the image repository on the worker queue") {
                    subject.fetchImageWithURL(expectedURL)

                    expect(imageRepository.lastReceivedURL).to(beNil())

                    workerQueue.lastReceivedBlock()

                    expect(imageRepository.lastReceivedURL).to(beIdenticalTo(expectedURL))
                }

                context("when the event repo calls the completion handler") {
                    it("resolves the promise on the result queue with the search result") {
                        let future = subject.fetchImageWithURL(expectedURL)
                        workerQueue.lastReceivedBlock()

                        let expectedImage = TestUtils.testImageNamed("bernie", type: "jpg")
                        imageRepository.lastRequestPromise.resolve(expectedImage)

                        expect(future.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.value).to(beIdenticalTo(expectedImage))
                    }
                }

                context("when the event repo calls the error handler") {
                    it("resolves the promise on the result queue with the error") {
                        let future = subject.fetchImageWithURL(expectedURL)
                        workerQueue.lastReceivedBlock()

                        let originalError = NSError(domain: "rr", code: 123, userInfo: nil)
                        let expectedError = ImageRepositoryError.DownloadError(error: originalError)

                        imageRepository.lastRequestPromise.reject(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        switch(future.error!) {
                        case ImageRepositoryError.DownloadError(let underlyingError):
                            expect(underlyingError).to(beIdenticalTo(originalError))
                        }
                    }
                }
            }
        }
    }
}
