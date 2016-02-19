import Foundation
import CBGPromise

class ConcreteJSONClient: JSONClient {
    private let urlSession: NSURLSession
    private let jsonSerializationProvider: NSJSONSerializationProvider

    init(urlSession: NSURLSession, jsonSerializationProvider: NSJSONSerializationProvider) {
        self.urlSession = urlSession
        self.jsonSerializationProvider = jsonSerializationProvider
    }

    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> JSONFuture {
        let promise = JSONPromise()

        var httpBody: NSData?
        if bodyDictionary !=  nil {
            do {
                httpBody = try self.jsonSerializationProvider.dataWithJSONObject(bodyDictionary!, options: NSJSONWritingOptions())
            } catch let error as NSError {
                let bodySerializationError = JSONClientError.BodySerializationError(error: error)
                promise.reject(bodySerializationError)
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

    func makeRequest(request: NSURLRequest, promise: JSONPromise) {
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                let networkError = JSONClientError.NetworkError(error: error)
                promise.reject(networkError)
                return
            }

            guard let httpResponse = response as? NSHTTPURLResponse else {
                let notAnHTTPResponseError = JSONClientError.NotAnHTTPResponseError(response: response!)
                promise.reject(notAnHTTPResponseError)
                return
            }

            if httpResponse.statusCode != 200 {
                let httpError = JSONClientError.HTTPStatusCodeError(statusCode: httpResponse.statusCode, data: data)
                promise.reject(httpError)
                return
            }

            var jsonBody: AnyObject?
            do {
                jsonBody = try self.jsonSerializationProvider.jsonObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            } catch let error as NSError {
                let jsonError = JSONClientError.JSONDeserializationError(error: error, data: data!)
                promise.reject(jsonError)
                return
            }

            promise.resolve(jsonBody!)
        })

        task.resume()
    }
}
