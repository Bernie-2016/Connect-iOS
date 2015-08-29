import Foundation
import Ono

public class ConcreteNewsItemRepository : NewsItemRepository {
    private let urlProvider: URLProvider!
    private let jsonClient: JSONClient!
    private let newsItemDeserializer: NewsItemDeserializer!
    private let operationQueue: NSOperationQueue!
    
    public init(
        urlProvider: URLProvider,
        jsonClient: JSONClient,
        newsItemDeserializer: NewsItemDeserializer,
        operationQueue: NSOperationQueue) {
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.newsItemDeserializer = newsItemDeserializer
            self.operationQueue = operationQueue
    }
    
    
    public func fetchNewsItems(completion: (Array<NewsItem>) -> Void, error: (NSError) -> Void) {
        var newsFeedJSONPromise = self.jsonClient.fetchJSONWithURL(self.urlProvider.newsFeedURL())
        
        newsFeedJSONPromise.then({ (jsonDictionary) -> AnyObject! in
            var parsedNewsItems = self.newsItemDeserializer.deserializeNewsItems(jsonDictionary as! NSDictionary)
            
            self.operationQueue.addOperationWithBlock({ () -> Void in
                completion(parsedNewsItems as Array<NewsItem>)
            })
            
            return parsedNewsItems
            }, error: { (receivedError) -> AnyObject! in
                self.operationQueue.addOperationWithBlock({ () -> Void in
                    error(receivedError)
                })
                return receivedError
        })
        
    }
}