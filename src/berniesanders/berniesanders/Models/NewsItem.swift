import Foundation

class NewsItem {
    let title: String
    let date: NSDate
    let body: String
    let imageURL: NSURL?
    let URL: NSURL

    init(title: String, date: NSDate, body: String, imageURL: NSURL?, URL: NSURL) {
        self.title = title
        self.date = date
        self.body = body
        self.imageURL = imageURL
        self.URL = URL
    }
}
