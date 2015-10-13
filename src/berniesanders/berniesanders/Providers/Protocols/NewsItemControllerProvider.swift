import Foundation

protocol NewsItemControllerProvider {
    func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController;
}
