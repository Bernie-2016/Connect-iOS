import Foundation

public class ConcreteNewsItemControllerProvider : NewsItemControllerProvider {
    public init() {
        
    }
    
    public func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController {
        return NewsItemController(newsItem: newsItem)
    }
}