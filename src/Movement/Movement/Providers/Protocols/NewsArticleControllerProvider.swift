import Foundation

protocol NewsFeedItemControllerProvider {
    func provideInstanceWithNewsFeedItem(newsFeedItem: NewsFeedItem) -> UIViewController
}
