import Foundation
import Ono

public class ConcreteIssueRepository : IssueRepository {
    let urlProvider: URLProvider!
    let xmlClient: XMLClient!
    let issueDeserializer: IssueDeserializer!
        
    public init(urlProvider: URLProvider, xmlClient: XMLClient, issueDeserializer: IssueDeserializer) {
        self.urlProvider = urlProvider
        self.xmlClient = xmlClient
        self.issueDeserializer = issueDeserializer
    }
    
    public func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        var issuesXMLPromise = self.xmlClient.fetchXMLDocumentWithURL(self.urlProvider.issuesFeedURL())

        issuesXMLPromise.then({ (xmlDocument) -> AnyObject! in
            var parsedIssues = self.issueDeserializer.deserializeIssues(xmlDocument as! ONOXMLDocument)
            completion(parsedIssues)
            return parsedIssues
        }, error: { (receivedError) -> AnyObject! in
            error(receivedError)
            return receivedError
        })
    }
}