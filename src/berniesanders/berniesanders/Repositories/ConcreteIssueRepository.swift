import Foundation

public class ConcreteIssueRepository : IssueRepository {
    let urlProvider: URLProvider!
    let jsonClient: JSONClient!
    let issueDeserializer: IssueDeserializer!
    let operationQueue: NSOperationQueue!
    
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
        var issuesJSONPromise = self.jsonClient.JSONPromiseWithURL(self.urlProvider.issuesFeedURL(), method: "POST", bodyDictionary: self.HTTPBodyDictionary())
        

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
    
    // MARK: Private
    
    func HTTPBodyDictionary() -> NSDictionary {
        return [
            "from": 0, "size": 30,
            "query": [
                "query_string": [
                    "default_field": "article_type",
                    "query": "Issues"
                ]
            ],
            "sort": [
                "created_at": ["order": "desc"]
            ]
        ]
    }
}