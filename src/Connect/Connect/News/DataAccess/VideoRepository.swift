import CBGPromise

enum VideoRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
    case NoMatchingVideo(identifier: VideoIdentifier)
}

extension VideoRepositoryError: Equatable {}

func == (lhs: VideoRepositoryError, rhs: VideoRepositoryError) -> Bool {
    switch (lhs, rhs) {
    case (.InvalidJSON, .InvalidJSON):
        return true // punt on this for now
    case (.ErrorInJSONClient(let lhsClientError), .ErrorInJSONClient(let rhsClientError)):
        return lhsClientError == rhsClientError
    case (.NoMatchingVideo(let lhsIdentifier), .NoMatchingVideo(let rhsIdentifier)):
        return lhsIdentifier == rhsIdentifier
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

typealias VideoFuture = Future<Video, VideoRepositoryError>
typealias VideoPromise = Promise<Video, VideoRepositoryError>
typealias VideosFuture = Future<Array<Video>, VideoRepositoryError>
typealias VideosPromise = Promise<Array<Video>, VideoRepositoryError>

protocol VideoRepository {
    func fetchVideos() -> VideosFuture
    func fetchVideo(identifier: VideoIdentifier) -> VideoFuture
}
