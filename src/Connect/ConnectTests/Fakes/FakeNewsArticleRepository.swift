import CBGPromise

@testable import Connect

class FakeNewsArticleRepository: NewsArticleRepository {
    var fetchNewsCalled: Bool = false
    var lastPromise: NewsArticlesPromise!

    func fetchNewsArticles() -> NewsArticlesFuture {
        self.fetchNewsCalled = true
        self.lastPromise = NewsArticlesPromise()
        return self.lastPromise.future
    }

    var lastFetchedNewsArticleIdentifier: NewsArticleIdentifier!
    var lastArticlePromise: NewsArticlePromise!
    func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture {
        lastFetchedNewsArticleIdentifier = identifier
        lastArticlePromise = NewsArticlePromise()
        return lastArticlePromise.future
    }
}
