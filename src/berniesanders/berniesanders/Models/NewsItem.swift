import Foundation

public class NewsItem {
    private(set) public var title: String!
    private(set) public var date: NSDate!
    private(set) public var body: String!
    private(set) public var imageURL: NSURL!
    
    public init(title: String, date: NSDate, body: String, imageURL: NSURL) {
        self.title = title
        self.date = date
        self.body = body
        self.imageURL = imageURL
    }
}