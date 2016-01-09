import CBGPromise

protocol VideoRepository {
    func fetchVideos() -> Future<Array<Video>, NSError>
}
