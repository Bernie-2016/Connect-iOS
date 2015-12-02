import Foundation


protocol NewsArticleRepository {
    func fetchNewsArticles(completion: ([NewsArticle]) -> Void, error: (NSError) -> Void)
}
