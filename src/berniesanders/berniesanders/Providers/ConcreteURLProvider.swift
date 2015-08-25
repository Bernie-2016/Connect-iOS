import Foundation

class ConcreteURLProvider : URLProvider {
    func issuesFeedURL() -> NSURL! {
        return NSURL(string: "https://berniesanders.com/issues/feed/")
    }
    
    func newsFeedURL() -> NSURL! {
        return NSURL(string: "https://berniesanders.com/feed/")
    }
}