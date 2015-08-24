import Foundation
import Ono

public class ConcreteIssueDeserializer : IssueDeserializer {
    public init() {
        
    }
    
    public func deserializeIssues(xmlDocument: ONOXMLDocument) -> Array<Issue> {
        var issues = [Issue]()
        
        xmlDocument.enumerateElementsWithXPath("//item", usingBlock: { (itemElement, index, stop) -> Void in
            var title = itemElement.firstChildWithXPath("title").stringValue()
            issues.append(Issue(title: title))
        })
        
        return issues
    }
}