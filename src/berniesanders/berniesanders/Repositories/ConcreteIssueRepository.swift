import Foundation

public class ConcreteIssueRepository : IssueRepository {
    private let urlProvider: URLProvider!
    private let jsonClient: JSONClient!
    private let issueDeserializer: IssueDeserializer!
    private let operationQueue: NSOperationQueue!
    
    public init(
        urlProvider: URLProvider,
        jsonClient: JSONClient,
        issueDeserializer: IssueDeserializer,
        operationQueue: NSOperationQueue) {
            
        self.urlProvider = urlProvider
        self.jsonClient = jsonClient
        self.issueDeserializer = issueDeserializer
        self.operationQueue = operationQueue
    }
    
    public func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        var issuesJSONPromise = self.jsonClient.fetchJSONWithURL(self.urlProvider.issuesFeedURL())
        

        issuesJSONPromise.then({ (jsonDictionary) -> AnyObject! in
            var parsedIssues = self.issueDeserializer.deserializeIssues(jsonDictionary as! NSDictionary)

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