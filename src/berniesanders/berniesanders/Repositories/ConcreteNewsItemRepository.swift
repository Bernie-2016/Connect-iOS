import Foundation
import Ono

public class ConcreteNewsItemRepository : NewsItemRepository {
    private let urlProvider: URLProvider!
    private let xmlClient: XMLClient!
    private let newsItemDeserializer: NewsItemDeserializer!
    private let operationQueue: NSOperationQueue!
    
    public init(
        urlProvider: URLProvider,
        xmlClient: XMLClient,
        newsItemDeserializer: NewsItemDeserializer,
        operationQueue: NSOperationQueue) {
            self.urlProvider = urlProvider
            self.xmlClient = xmlClient
            self.newsItemDeserializer = newsItemDeserializer
            self.operationQueue = operationQueue
    }
    
    
    public func fetchNewsItems(completion: (Array<NewsItem>) -> Void, error: (NSError) -> Void) {
        var newsFeedXMLPromise = self.xmlClient.fetchXMLDocumentWithURL(self.urlProvider.newsFeedURL())
        
        newsFeedXMLPromise.then({ (xmlDocument) -> AnyObject! in
            var parsedNewsItems = self.newsItemDeserializer.deserializeNewsItems(xmlDocument as! ONOXMLDocument)
            
            self.operationQueue.addOperationWithBlock({ () -> Void in
                completion(parsedNewsItems)
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