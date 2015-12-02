import Foundation


protocol NewsArticleRepository {
    func fetchNewsArticles(completion: (Array<NewsArticle>) -> Void, error: (NSError) -> Void)
}
