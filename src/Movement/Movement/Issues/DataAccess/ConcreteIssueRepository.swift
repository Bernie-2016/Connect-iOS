import Foundation

class ConcreteIssueRepository: IssueRepository {
    private let urlProvider: URLProvider
    private let jsonClient: JSONClient
    private let issueDeserializer: IssueDeserializer

    init(urlProvider: URLProvider,
         jsonClient: JSONClient,
         issueDeserializer: IssueDeserializer) {
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.issueDeserializer = issueDeserializer
    }

    func fetchIssues() -> IssuesFuture {
        let promise = IssuesPromise()

        let issuesJSONFuture = self.jsonClient.JSONPromiseWithURL(self.urlProvider.issuesFeedURL(), method: "POST", bodyDictionary: self.HTTPBodyDictionary())

        issuesJSONFuture.then { deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = IssueRepositoryError.InvalidJSON(jsonObject: deserializedObject)
                promise.reject(incorrectObjectTypeError)
                return
            }

            let parsedIssues = self.issueDeserializer.deserializeIssues(jsonDictionary)
            promise.resolve(parsedIssues)
        }

        issuesJSONFuture.error { receivedError in
            let jsonClientError = IssueRepositoryError.ErrorInJSONClient(error: receivedError)
            promise.reject(jsonClientError)
        }

        return promise.future
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
