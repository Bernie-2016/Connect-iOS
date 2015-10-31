import Foundation

class NewsItem {
    let title: String
    let date: NSDate
    let body: String
    let excerpt: String
    let imageURL: NSURL?
    let url: NSURL

    init(title: String, date: NSDate, body: String, excerpt: String, imageURL: NSURL?, url: NSURL) {
        self.title = title
        self.date = date
        self.body = body
        self.excerpt = excerpt
        self.imageURL = imageURL
        self.url = url
    }
}
