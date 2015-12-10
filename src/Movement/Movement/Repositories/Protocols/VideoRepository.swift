import BrightFutures

protocol VideoRepository {
    func fetchVideos() -> Future<Array<Video>, NSError>
}
