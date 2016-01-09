import Foundation
import CBGPromise

class ConcreteNewsArticleRepository: NewsArticleRepository {
    private let urlProvider: URLProvider
    private let jsonClient: JSONClient
    private let newsArticleDeserializer: NewsArticleDeserializer

    init(
        urlProvider: URLProvider,
        jsonClient: JSONClient,
        newsArticleDeserializer: NewsArticleDeserializer) {
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.newsArticleDeserializer = newsArticleDeserializer
    }

    func fetchNewsArticles() -> Future<Array<NewsArticle>, NSError> {
        let promise = Promise<Array<NewsArticle>, NSError>()

        let newsFeedJSONFuture = self.jsonClient.JSONPromiseWithURL(self.urlProvider.newsFeedURL(), method: "POST", bodyDictionary: self.HTTPBodyDictionary())

        newsFeedJSONFuture.then({ deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = NSError(domain: "ConcreteNewsArticleRepository", code: -1, userInfo: nil)
                promise.reject(incorrectObjectTypeError)
                return
            }

            let parsedNewsArticles = self.newsArticleDeserializer.deserializeNewsArticles(jsonDictionary)

            promise.resolve(parsedNewsArticles as [NewsArticle])
        })

        newsFeedJSONFuture.error { receivedError in
            promise.reject(receivedError)
        }

        return promise.future
    }

    // MARK: Private

    func HTTPBodyDictionary() -> NSDictionary {
        return [
            "from": 0, "size": 30,
            "_source": ["title", "body", "excerpt", "created_at", "url", "image_url"],
            "query": [
                "query_string": [
                    "default_field": "article_type",
                    "query": "NOT ExternalLink OR NOT Issues"
                ]
            ],
            "sort": [
                "created_at": ["order": "desc"]
            ]
        ]
    }
}
