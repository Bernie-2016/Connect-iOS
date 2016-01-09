import Foundation

class BackgroundImageService: ImageService {
    private let imageRepository: ImageRepository
    private let workerQueue: NSOperationQueue
    private let resultQueue: NSOperationQueue

    init(imageRepository: ImageRepository, workerQueue: NSOperationQueue, resultQueue: NSOperationQueue) {
        self.imageRepository = imageRepository
        self.workerQueue = workerQueue
        self.resultQueue = resultQueue
    }


    func fetchImageWithURL(url: NSURL) -> ImageFuture {
        let promise = ImagePromise()

        workerQueue.addOperationWithBlock {
            let imageFuture = self.imageRepository.fetchImageWithURL(url)
            imageFuture.then { image in
                self.resultQueue.addOperationWithBlock {
                    promise.resolve(image)
                }
            }

            imageFuture.error { error in
                self.resultQueue.addOperationWithBlock {
                    promise.reject(error)
                }
            }
        }
        return promise.future
    }
}
