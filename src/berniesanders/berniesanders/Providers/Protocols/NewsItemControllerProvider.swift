import Foundation

public protocol NewsItemControllerProvider {
    func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController;
}