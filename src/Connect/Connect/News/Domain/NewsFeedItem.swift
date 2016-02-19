import Foundation

protocol NewsFeedItem {
    var title: String { get }
    var date: NSDate { get }
    var identifier: String { get }
}
