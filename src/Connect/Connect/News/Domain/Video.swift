import Foundation

typealias VideoIdentifier = String

class Video: NewsFeedItem {
    let title: String
    let date: NSDate
    let identifier: VideoIdentifier
    let description: String

    init(title: String, date: NSDate, identifier: VideoIdentifier, description: String) {
        self.title = title
        self.date = date
        self.identifier = identifier
        self.description = description
    }
}
