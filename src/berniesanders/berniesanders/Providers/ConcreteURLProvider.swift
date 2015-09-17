import Foundation

class ConcreteURLProvider : URLProvider {
    func issuesFeedURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search?q=article_type:Issues&sort=created_at:desc")
    }
    
    func newsFeedURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search?q=!article_type%3A(ExternalLink%20OR%20Issues)&sort=created_at:desc")
    }
    
    func bernieCrowdURL() -> NSURL! {
        return NSURL(string: "https://berniecrowd.org/")
    }
    
    func bernieEventsURL() -> NSURL! {
         return NSURL(string: "https://berniesanders.com/events")       
    }
    
    func privacyPolicyURL() -> NSURL! {
        return NSURL(string: "https://www.iubenda.com/privacy-policy/128001")
    }
}