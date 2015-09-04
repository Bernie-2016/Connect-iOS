import Foundation

public class NewsItem {
    public let title: String!
    public let date: NSDate!
    public let body: String!
    public let imageURL: NSURL!
    
    public init(title: String, date: NSDate, body: String, imageURL: NSURL) {
        self.title = title
        self.date = date
        self.body = body
        self.imageURL = imageURL
    }
}