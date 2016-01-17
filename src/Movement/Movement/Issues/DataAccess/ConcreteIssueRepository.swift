import Foundation

class ConcreteIssueRepository: IssueRepository {
    private let urlProvider: URLProvider
    private let jsonClient: JSONClient
    private let issueDeserializer: IssueDeserializer

    init(
        urlProvider: URLProvider,
        jsonClient: JSONClient,
        issueDeserializer: IssueDeserializer) {
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.issueDeserializer = issueDeserializer
    }

    func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        let issuesJSONFuture = self.jsonClient.JSONPromiseWithURL(self.urlProvider.issuesFeedURL(), method: "POST", bodyDictionary: self.HTTPBodyDictionary())

        issuesJSONFuture.then { deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = NSError(domain: "ConcreteIssueRepository", code: -1, userInfo: nil)

                error(incorrectObjectTypeError)
                return
            }

            let parsedIssues = self.issueDeserializer.deserializeIssues(jsonDictionary)

            completion(parsedIssues)
        }

        issuesJSONFuture.error { receivedError in
            error(receivedError)
        }
    }

    // MARK: Private

    private func HTTPBodyDictionary() -> NSDictionary {
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
                "timestamp_publish": ["order": "desc", "ignore_unmapped": true]
            ]
        ]
    }
}
