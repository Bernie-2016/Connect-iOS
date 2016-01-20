import Foundation
import CBGPromise

enum JSONClientError: ErrorType {
    case BodySerializationError(error: NSError)
    case NetworkError(error: NSError?)
    case NotAnHTTPResponseError(response: NSURLResponse)
    case HTTPStatusCodeError(statusCode: Int, data: NSData?)
    case JSONDeserializationError(error: NSError, data: NSData?)
}

typealias JSONFuture = Future<AnyObject, JSONClientError>
typealias JSONPromise = Promise<AnyObject, JSONClientError>

protocol JSONClient {
    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> JSONFuture
}
