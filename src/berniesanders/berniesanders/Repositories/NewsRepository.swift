import Foundation


public protocol NewsRepository {
    func fetchNews(completion:(Array<NewsItem>) -> Void, error:(NSError) -> Void)
}