import Foundation

public class NewsItem {
    public let title: String
    public let date: NSDate
    public let body: String
    public let imageURL: NSURL?
    public let URL: NSURL
    
    public init(title: String, date: NSDate, body: String, imageURL: NSURL?, URL: NSURL) {
        self.title = title
        self.date = date
        self.body = body
        self.imageURL = imageURL
        self.URL = URL
    }
}