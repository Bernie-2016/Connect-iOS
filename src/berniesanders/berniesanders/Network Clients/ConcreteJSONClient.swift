import Foundation
import KSDeferred

class ConcreteJSONClient: JSONClient {
    struct Error {
        static let BadResponse = "BadResponse"
    }

    private let urlSession: NSURLSession
    private let jsonSerializationProvider: NSJSONSerializationProvider

    init(urlSession: NSURLSession, jsonSerializationProvider: NSJSONSerializationProvider) {
        self.urlSession = urlSession
        self.jsonSerializationProvider = jsonSerializationProvider
    }

    func JSONPromiseWithURL(url: NSURL, method: String, bodyDictionary: NSDictionary?) -> KSPromise {
        let deferred = KSDeferred()

        var jsonSerializationError : NSError?
        let httpBody : NSData?
        if(bodyDictionary !=  nil) {
            do {
                httpBody = try self.jsonSerializationProvider.dataWithJSONObject(bodyDictionary!, options: NSJSONWritingOptions())
            } catch let error as NSError {
                jsonSerializationError = error
                httpBody = nil
            }
        } else {
            httpBody = nil
        }

        if(jsonSerializationError != nil) {
            deferred.rejectWithError(jsonSerializationError)
            return deferred.promise
        }

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.HTTPBody = httpBody

        let task = self.urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if(error != nil) {
                deferred.rejectWithError(error)
                return
            }

            let httpResponse = response as! NSHTTPURLResponse
            if(httpResponse.statusCode != 200) {
                let httpError = NSError(domain: ConcreteJSONClient.Error.BadResponse, code: httpResponse.statusCode, userInfo: nil)
                deferred.rejectWithError(httpError)
                return
            }

            var jsonDeserializationError : NSError?
            var jsonBody: AnyObject?
            do {
                jsonBody = try self.jsonSerializationProvider.jsonObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            } catch let error as NSError {
                jsonDeserializationError = error
                jsonBody = nil
            } catch {
                fatalError()
            }
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
