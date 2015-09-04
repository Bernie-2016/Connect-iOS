import Foundation

public class Issue {
    public let title: String!
    public let body: String!
    public let imageURL: NSURL!
    
    public init(title: String, body: String, imageURL: NSURL) {
        self.title = title
        self.body = body
        self.imageURL = imageURL
    }
}