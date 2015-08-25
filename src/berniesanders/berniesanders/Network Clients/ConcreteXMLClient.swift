import Foundation
import KSDeferred

public class ConcreteXMLClient : XMLClient {
    let urlSession: NSURLSession
    let onoXMLDocumentProvider: ONOXMLDocumentProvider
    
    public init(urlSession: NSURLSession, onoXMLDocumentProvider: ONOXMLDocumentProvider) {
        self.urlSession = urlSession
        self.onoXMLDocumentProvider = onoXMLDocumentProvider
    }
    
    public func fetchXMLDocumentWithURL(url: NSURL) -> KSPromise {
        var deferred = KSDeferred.defer()

        var task = self.urlSession.dataTaskWithURL(url) { (data, response, error) -> Void in
            if(error != nil) {
                deferred.rejectWithError(error)
                return
            }
            
            var httpResponse = response as! NSHTTPURLResponse
            if(httpResponse.statusCode != 200) {
                var httpError = NSError(domain: ConcreteXMLClient.Error.BadResponse, code: httpResponse.statusCode, userInfo: nil)
                deferred.rejectWithError(httpError)
                return
            }
            
            var xmlError : NSError?
            var xmlDocument = self.onoXMLDocumentProvider.provideXMLDocument(data, error: &xmlError)
            if xmlError != nil {
                deferred.rejectWithError(xmlError)
            } else {
                deferred.resolveWithValue(xmlDocument)
            }
        }
        task.resume()
        
        return deferred.promise
    }
    
    public struct Error {
        public static let BadResponse = "BadResponse"
    }
}
