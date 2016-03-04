import CBGPromise

enum VideoRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
}

typealias VideosFuture = Future<Array<Video>, VideoRepositoryError>
typealias VideosPromise = Promise<Array<Video>, VideoRepositoryError>

protocol VideoRepository {
    func fetchVideos() -> VideosFuture
}
