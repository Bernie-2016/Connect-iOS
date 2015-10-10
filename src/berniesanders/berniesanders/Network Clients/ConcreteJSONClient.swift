import Foundation
import KSDeferred

public class ConcreteJSONClient: JSONClient {
    public struct Error {
        public static let BadResponse = "BadResponse"
    }

    private let urlSession: NSURLSession
    private let jsonSerializationProvider: NSJSONSerializationProvider

    public init(urlSession: NSURLSession, jsonSerializationProvider: NSJSONSerializationProvider) {
        self.urlSession = urlSession
        self.jsonSerializationProvider = jsonSerializationProvider
    }

    public func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> KSPromise {
        let deferred = KSDeferred()

        var jsonSerializationError : NSError?
        let httpBody : NSData?
        if(bodyDictionary !=  nil) {
            httpBody = self.jsonSerializationProvider.dataWithJSONObject(bodyDictionary!, options: NSJSONWritingOptions.allZeros, error: &jsonSerializationError)
        } else {
            httpBody = nil
        }

        if(jsonSerializationError != nil) {
            deferred.rejectWithError(jsonSerializationError)
            return deferred.promise
        }

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method

        var jsonError : NSError?

        request.HTTPBody = httpBody

        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if(error != nil) {
                deferred.rejectWithError(error)
                return
            }

            var httpResponse = response as! NSHTTPURLResponse
            if(httpResponse.statusCode != 200) {
                var httpError = NSError(domain: ConcreteJSONClient.Error.BadResponse, code: httpResponse.statusCode, userInfo: nil)
                deferred.rejectWithError(httpError)
                return
            }

            var jsonDeserializationError : NSError?
            var jsonBody: AnyObject? = self.jsonSerializationProvider.jsonObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonDeserializationError)
            if jsonDeserializationError != nil {
                deferred.rejectWithError(jsonDeserializationError)
            } else {
                deferred.resolveWithValue(jsonBody)
            }
        })

        task.resume()

        return deferred.promise
    }
}
