import Foundation


protocol NewsItemRepository {
    func fetchNewsItems(completion: (Array<NewsItem>) -> Void, error: (NSError) -> Void)
}
