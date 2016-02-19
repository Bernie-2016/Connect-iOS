import CBGPromise


protocol NewsArticleService {
    func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture
}
