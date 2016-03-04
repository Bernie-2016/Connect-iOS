import Foundation

protocol VideoService {
    func fetchVideo(identifier: VideoIdentifier) -> VideoFuture
}

class BackgroundVideoService: VideoService {
    let videoRepository: VideoRepository
    let workerQueue: NSOperationQueue
    let resultQueue: NSOperationQueue

    init(videoRepository: VideoRepository,
        workerQueue: NSOperationQueue,
        resultQueue: NSOperationQueue) {
            self.videoRepository = videoRepository
            self.workerQueue = workerQueue
            self.resultQueue = resultQueue
    }

    func fetchVideo(identifier: VideoIdentifier) -> VideoFuture {
        let promise = VideoPromise()

        workerQueue.addOperationWithBlock {
            let videoFuture = self.videoRepository.fetchVideo(identifier)

            videoFuture.then { video in
                self.resultQueue.addOperationWithBlock { promise.resolve(video) }
                }.error { error in
                    self.resultQueue.addOperationWithBlock { promise.reject(error) }
            }
        }

        return promise.future
    }
}
