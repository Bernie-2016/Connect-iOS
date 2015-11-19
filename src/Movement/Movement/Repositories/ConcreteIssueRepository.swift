import Foundation

class ConcreteIssueRepository: IssueRepository {
    private let urlProvider: URLProvider
    private let jsonClient: JSONClient
    private let issueDeserializer: IssueDeserializer
    private let operationQueue: NSOperationQueue

    init(
        urlProvider: URLProvider,
        jsonClient: JSONClient,
        issueDeserializer: IssueDeserializer,
        operationQueue: NSOperationQueue) {
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.issueDeserializer = issueDeserializer
            self.operationQueue = operationQueue
    }

    func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        let issuesJSONPromise = self.jsonClient.JSONPromiseWithURL(self.urlProvider.issuesFeedURL(), method: "POST", bodyDictionary: self.HTTPBodyDictionary())

        issuesJSONPromise.then({ (deserializedObject) -> AnyObject! in
            let jsonDictionary = deserializedObject as? NSDictionary
            if jsonDictionary == nil {
                let incorrectObjectTypeError = NSError(domain: "ConcreteIssueRepository", code: -1, userInfo: nil)

                self.operationQueue.addOperationWithBlock({ () -> Void in
                    error(incorrectObjectTypeError)
                })
                return incorrectObjectTypeError
            }

            let parsedIssues = self.issueDeserializer.deserializeIssues(jsonDictionary!)

            self.operationQueue.addOperationWithBlock({ () -> Void in
                completion(parsedIssues)
            })

            return parsedIssues
        }, error: { (receivedError) -> AnyObject! in
            self.operationQueue.addOperationWithBlock({ () -> Void in
                error(receivedError!)
                })
            return receivedError
        })
    }

    // MARK: Private

    func HTTPBodyDictionary() -> NSDictionary {
        return [
            "from": 0, "size": 30,
            "_source": ["title", "body", "url", "image_url"],
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
