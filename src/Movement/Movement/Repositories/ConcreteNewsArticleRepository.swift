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

    func fetchNewsArticles() -> NewsArticlesFuture {
        let promise = NewsArticlesPromise()

        let newsFeedJSONFuture = self.jsonClient.JSONPromiseWithURL(urlProvider.newsFeedURL(), method: "POST", bodyDictionary: ArticlesHTTPBodyDictionary())

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

    func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture {
        let promise = NewsArticlePromise()

        let newsFeedJSONFuture = self.jsonClient.JSONPromiseWithURL(urlProvider.newsFeedURL(), method: "POST", bodyDictionary: ArticleHTTPBodyDictionary(identifier))

        newsFeedJSONFuture.then({ deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = NSError(domain: "ConcreteNewsArticleRepository", code: -1, userInfo: nil)
                promise.reject(incorrectObjectTypeError)
                return
            }

            let parsedNewsArticles = self.newsArticleDeserializer.deserializeNewsArticles(jsonDictionary)

            guard let newsArticle = parsedNewsArticles.first else {
                let noMatchingNewsArticleError = NSError(domain: "ConcreteNewsArticleRepository", code: 1, userInfo: nil)
                promise.reject(noMatchingNewsArticleError)
                return
            }
            promise.resolve(newsArticle)
        })

        newsFeedJSONFuture.error { receivedError in
            promise.reject(receivedError)
        }

        return promise.future
    }

    // MARK: Private

    private func ArticlesHTTPBodyDictionary() -> NSDictionary {
        return [
            "from": 0, "size": 30,
            "_source": ["title", "body", "excerpt", "timestamp_publish", "url", "image_url"],
            "query": [
                "query_string": [
                    "default_field": "article_type",
                    "query": "NOT ExternalLink OR NOT Issues"
                ]
            ],
            "sort": [
                "timestamp_publish": ["order": "desc", "ignore_unmapped": true]
            ]
        ]
    }

    private func ArticleHTTPBodyDictionary(identifier: NewsArticleIdentifier) -> NSDictionary {
        return [
            "from": 0, "size": 1,
            "_source": ["title", "body", "excerpt", "timestamp_publish", "url", "image_url"],
            "filter": [
                "term": [
                    "_id": identifier,
                ]
            ]
        ]
    }
}
