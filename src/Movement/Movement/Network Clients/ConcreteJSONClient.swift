import Foundation
import CBGPromise
import Result

class ConcreteJSONClient: JSONClient {
    struct Error {
        static let badResponse = "badResponse"
    }

    private let urlSession: NSURLSession
    private let jsonSerializationProvider: NSJSONSerializationProvider

    init(urlSession: NSURLSession, jsonSerializationProvider: NSJSONSerializationProvider) {
        self.urlSession = urlSession
        self.jsonSerializationProvider = jsonSerializationProvider
    }

    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> Future<AnyObject, NSError> {
        let promise = Promise<AnyObject, NSError>()

        var httpBody: NSData?
        if bodyDictionary !=  nil {
            do {
                httpBody = try self.jsonSerializationProvider.dataWithJSONObject(bodyDictionary!, options: NSJSONWritingOptions())
            } catch let error as NSError {
                promise.reject(error)
                return promise.future
            }
        }

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.HTTPBody = httpBody

        self.makeRequest(request, promise: promise)

        return promise.future
    }

    // MARK: Private

    func makeRequest(request: NSURLRequest, promise: Promise<AnyObject, NSError>) {
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                promise.reject(error!)
                return
            }

            guard let httpResponse = response as? NSHTTPURLResponse else {
                let httpResponseUnwrappingError = NSError(domain: ConcreteJSONClient.Error.badResponse, code: -1, userInfo: nil)
                promise.reject(httpResponseUnwrappingError)
                return
            }

            if httpResponse.statusCode != 200 {
                let httpError = NSError(domain: ConcreteJSONClient.Error.badResponse, code: httpResponse.statusCode, userInfo: nil)
                promise.reject(httpError)
                return
            }

            var jsonBody: AnyObject?
            do {
                jsonBody = try self.jsonSerializationProvider.jsonObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            } catch let error as NSError {
                promise.reject(error)
                return
            }

            promise.resolve(jsonBody!)
        })

        task.resume()
    }
}
