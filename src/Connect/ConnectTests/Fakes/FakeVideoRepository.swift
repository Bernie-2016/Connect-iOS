@testable import Connect

class FakeVideoRepository: VideoRepository {
    var fetchVideosCalled: Bool = false
    var lastPromise: VideosPromise!

    func fetchVideos() -> VideosFuture {
        self.fetchVideosCalled = true
        self.lastPromise = VideosPromise()
        return self.lastPromise.future
    }

    var lastFetchedVideoIdentifier: VideoIdentifier!
    var lastVideoPromise: VideoPromise!
    func fetchVideo(identifier: VideoIdentifier) -> VideoFuture {
        lastFetchedVideoIdentifier = identifier
        lastVideoPromise = VideoPromise()
        return lastVideoPromise.future
    }
}
