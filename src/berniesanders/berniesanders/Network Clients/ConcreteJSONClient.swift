import Foundation
import KSDeferred

public class ConcreteJSONClient : JSONClient {
    let urlSession: NSURLSession
    let jsonSerializationProvider: NSJSONSerializationProvider
    
    public init(urlSession: NSURLSession, jsonSerializationProvider: NSJSONSerializationProvider) {
        self.urlSession = urlSession
        self.jsonSerializationProvider = jsonSerializationProvider
    }
    
    public func fetchJSONWithURL(url: NSURL) -> KSPromise {
        var deferred = KSDeferred.defer()
        
        var task = self.urlSession.dataTaskWithURL(url) { (data, response, error) -> Void in
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
            
            var jsonError : NSError?
            var jsonBody: AnyObject? = self.jsonSerializationProvider.jsonObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
            if jsonError != nil {
                deferred.rejectWithError(jsonError)
            } else {
                deferred.resolveWithValue(jsonBody)
            }
        }
        task.resume()
        
        return deferred.promise
    }
    
    public struct Error {
        public static let BadResponse = "BadResponse"
    }

}
