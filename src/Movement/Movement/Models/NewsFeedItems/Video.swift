import Foundation

class Video: NewsFeedItem {
    let title: String
    let date: NSDate
    let identifier: String
    let description: String

    init(title: String, date: NSDate, identifier: String, description: String) {
        self.title = title
        self.date = date
        self.identifier = identifier
        self.description = description
    }
}
