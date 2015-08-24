import Foundation
import Ono

public class ConcreteIssueRepository : IssueRepository {
    let urlProvider: URLProvider!
    let xmlClient: XMLClient!
    let issueDeserializer: IssueDeserializer!
    let operationQueue: NSOperationQueue!
    public init(
        urlProvider: URLProvider,
        xmlClient: XMLClient,
        issueDeserializer: IssueDeserializer,
        operationQueue: NSOperationQueue) {
            
        self.urlProvider = urlProvider
        self.xmlClient = xmlClient
        self.issueDeserializer = issueDeserializer
        self.operationQueue = operationQueue
    }
    
    public func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        var issuesXMLPromise = self.xmlClient.fetchXMLDocumentWithURL(self.urlProvider.issuesFeedURL())

        issuesXMLPromise.then({ (xmlDocument) -> AnyObject! in
            var parsedIssues = self.issueDeserializer.deserializeIssues(xmlDocument as! ONOXMLDocument)
            
            self.operationQueue.addOperationWithBlock({ () -> Void in
                completion(parsedIssues)
            })

            return parsedIssues
        }, error: { (receivedError) -> AnyObject! in
            self.operationQueue.addOperationWithBlock({ () -> Void in
                error(receivedError)
                })
            return receivedError
        })
    }
}