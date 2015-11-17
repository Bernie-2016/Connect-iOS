import Foundation
import KSDeferred

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

    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> KSPromise {
        let deferred = KSDeferred()

        var httpBody: NSData?
        if bodyDictionary !=  nil {
            do {
                httpBody = try self.jsonSerializationProvider.dataWithJSONObject(bodyDictionary!, options: NSJSONWritingOptions())
            } catch let error as NSError {
                deferred.rejectWithError(error)
                return deferred.promise
            }
        }

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.HTTPBody = httpBody

        self.makeRequest(request, withDeferred: deferred)

        return deferred.promise
    }

    // MARK: Private

    func makeRequest(request: NSURLRequest, withDeferred deferred: KSDeferred) {
        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                deferred.rejectWithError(error)
                return
            }

            guard let httpResponse = response as? NSHTTPURLResponse else {
                let httpResponseUnwrappingError = NSError(domain: ConcreteJSONClient.Error.badResponse, code: -1, userInfo: nil)
                deferred.rejectWithError(httpResponseUnwrappingError)
                return
            }

            if httpResponse.statusCode != 200 {
                let httpError = NSError(domain: ConcreteJSONClient.Error.badResponse, code: httpResponse.statusCode, userInfo: nil)
                deferred.rejectWithError(httpError)
                return
            }

            var jsonBody: AnyObject?
            do {
                jsonBody = try self.jsonSerializationProvider.jsonObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            } catch let error as NSError {
                deferred.rejectWithError(error)
                return
            }

            deferred.resolveWithValue(jsonBody)
        })

        task.resume()
    }
}
