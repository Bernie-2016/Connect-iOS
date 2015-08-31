import Foundation

class ConcreteURLProvider : URLProvider {
    func issuesFeedURL() -> NSURL! {
        return NSURL(string: "https://berniesanders.com/issues/feed/")
    }
    
    func newsFeedURL() -> NSURL! {
        return NSURL(string: "http://search.berniesanders.tech/sites_en/official/_search?sort=published_time:desc")
    }
}