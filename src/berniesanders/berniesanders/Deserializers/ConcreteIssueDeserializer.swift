import Foundation

public class ConcreteIssueDeserializer : IssueDeserializer {
    public init() {
        
    }
    
    public func deserializeIssues(jsonDictionary: NSDictionary) -> Array<Issue> {
        var issues = [Issue]()
        
        var hitsDictionary = jsonDictionary["hits"] as? NSDictionary;
        
        if (hitsDictionary == nil) {
            return issues
        }
        
        var issueDictionaries = hitsDictionary!["hits"] as? Array<NSDictionary>;
        
        if (issueDictionaries == nil) {
            return issues
        }
        
        for(issueDictionary: NSDictionary) in issueDictionaries! {
            var sourceDictionary = issueDictionary["_source"] as? NSDictionary;
            
            if (sourceDictionary == nil) {
                continue
            }
            
            var title = sourceDictionary!["title"] as? String
            var body = sourceDictionary!["body"] as? String
            
            if (title == nil) || (body == nil) {
                continue;
            }
            
            var imageURLString = sourceDictionary!["image_url"] as? String
            var imageURL : NSURL?

            if((imageURLString) != nil) {
                imageURL = NSURL(string: imageURLString!)
            }

            var issue = Issue(title: title!, body: body!, imageURL: imageURL)
            issues.append(issue);
        }
        
        return issues
    }
}