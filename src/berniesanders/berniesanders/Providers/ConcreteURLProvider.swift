import Foundation

class ConcreteURLProvider : URLProvider {
    func issuesFeedURL() -> NSURL! {
        return NSURL(string: "http://23.253.159.164/sites_en/official/_search?q=article_type:Issues&sort=published_time:desc")
    }
    
    func newsFeedURL() -> NSURL! {
        return NSURL(string: "http://23.253.159.164/sites_en/official/_search?sort=published_time:desc")
    }
    
    func bernieCrowdURL() -> NSURL! {
        return NSURL(string: "https://berniecrowd.org/")
    }
}