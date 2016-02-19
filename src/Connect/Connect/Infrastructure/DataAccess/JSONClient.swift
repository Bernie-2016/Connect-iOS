import Foundation
import CBGPromise

enum JSONClientError: ErrorType {
    case BodySerializationError(error: NSError)
    case NetworkError(error: NSError?)
    case NotAnHTTPResponseError(response: NSURLResponse)
    case HTTPStatusCodeError(statusCode: Int, data: NSData?)
    case JSONDeserializationError(error: NSError, data: NSData?)
}

extension JSONClientError: Equatable {}

func == (lhs: JSONClientError, rhs: JSONClientError) -> Bool {
    switch (lhs, rhs) {
    case (.BodySerializationError(let lhsError), .BodySerializationError(let rhsError)):
        return lhsError == rhsError
    case (.NetworkError(let lhsError), .BodySerializationError(let rhsError)):
        return lhsError == rhsError
    case (.NotAnHTTPResponseError(let lhsResponse), .NotAnHTTPResponseError(let rhsResponse)):
        return lhsResponse == rhsResponse
    case (.HTTPStatusCodeError(let lhsStatusCode, let lhsData), .HTTPStatusCodeError(let rhsStatusCode, let rhsData)):
        return lhsStatusCode == rhsStatusCode && lhsData == rhsData
    case (.JSONDeserializationError(let lhsError, let lhsData), .JSONDeserializationError(let rhsError, let rhsData)):
        return lhsError == rhsError && lhsData == rhsData
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}


typealias JSONFuture = Future<AnyObject, JSONClientError>
typealias JSONPromise = Promise<AnyObject, JSONClientError>

protocol JSONClient {
    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> JSONFuture
}
