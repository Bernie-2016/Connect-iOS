import CBGPromise

enum VideoRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
}

typealias VideoFuture = Future<Array<Video>, VideoRepositoryError>
typealias VideoPromise = Promise<Array<Video>, VideoRepositoryError>

protocol VideoRepository {
    func fetchVideos() -> VideoFuture
}
