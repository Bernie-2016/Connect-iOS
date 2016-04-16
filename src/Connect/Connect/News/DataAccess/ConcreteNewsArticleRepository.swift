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
                let incorrectObjectTypeError = NewsArticleRepositoryError.InvalidJSON(jsonObject: deserializedObject)
                promise.reject(incorrectObjectTypeError)
                return
            }

            let parsedNewsArticles = self.newsArticleDeserializer.deserializeNewsArticles(jsonDictionary)

            promise.resolve(parsedNewsArticles as [NewsArticle])
        })

        newsFeedJSONFuture.error { receivedError in
            let error = NewsArticleRepositoryError.ErrorInJSONClient(error: receivedError)
            promise.reject(error)
        }

        return promise.future
    }

    func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture {
        let promise = NewsArticlePromise()

        let newsArticleJSONFuture = self.jsonClient.JSONPromiseWithURL(urlProvider.newsFeedURL(), method: "POST", bodyDictionary: ArticleHTTPBodyDictionary(identifier))

        newsArticleJSONFuture.then({ deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = NewsArticleRepositoryError.InvalidJSON(jsonObject: deserializedObject)
                promise.reject(incorrectObjectTypeError)
                return
            }

            let parsedNewsArticles = self.newsArticleDeserializer.deserializeNewsArticles(jsonDictionary)

            guard let newsArticle = parsedNewsArticles.first else {
                let noMatchingArticleError = NewsArticleRepositoryError.NoMatchingNewsArticle(identifier: identifier)
                promise.reject(noMatchingArticleError)
                return
            }
            promise.resolve(newsArticle)
        })

        newsArticleJSONFuture.error { receivedError in
            let error = NewsArticleRepositoryError.ErrorInJSONClient(error: receivedError)
            promise.reject(error)
        }


        return promise.future
    }

    // MARK: Private

    private func ArticlesHTTPBodyDictionary() -> NSDictionary {
        return [
            "from": 0, "size": 30,
            "_source": ["title", "body_markdown", "excerpt", "timestamp_publish", "url", "image_url"],
            "query": [
                "query_string": [
                    "default_field": "article_type",
                    "query": "PressRelease OR DemocracyDaily OR News"
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
            "_source": ["title", "body_markdown", "excerpt", "timestamp_publish", "url", "image_url"],
            "filter": [
                "term": [
                    "_id": identifier,
                ]
            ]
        ]
    }
}
