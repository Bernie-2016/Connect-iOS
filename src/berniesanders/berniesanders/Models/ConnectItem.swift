import Foundation

public class ConnectItem {
    private(set) public var title: String!
    private(set) public var date: NSDate!
    
    public init(title: String, date: NSDate) {
        self.title = title
        self.date = date
    }
}