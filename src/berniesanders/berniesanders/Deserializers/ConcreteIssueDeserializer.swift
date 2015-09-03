import Foundation

public class ConcreteIssueDeserializer : IssueDeserializer {
    public init() {
        
    }
    
    public func deserializeIssues(jsonDictionary: NSDictionary) -> Array<Issue> {
        var issues = [Issue]()
        
        var hitsDictionary = jsonDictionary["hits"] as! NSDictionary;
        var issueDictionaries = hitsDictionary["hits"] as! Array<NSDictionary>;
        for(issueDictionary: NSDictionary) in issueDictionaries {
            var sourceDictionary = issueDictionary["_source"] as! NSDictionary;
            var title = sourceDictionary["title"] as! String
            
            var issue = Issue(title: title)
            issues.append(issue);
        }
        
        return issues
    }
}