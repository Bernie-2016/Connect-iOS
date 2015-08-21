import Foundation

class ConcreteNewsRepository : NewsRepository {
    func fetchNews(completion: (Array<NewsItem>) -> Void, error: (NSError) -> Void) {
        var newsItemA = NewsItem(title: "Bernie is awesome")
        var newsItemB = NewsItem(title: "Bernie for President!")
        
        completion([newsItemA, newsItemB])
    }
}