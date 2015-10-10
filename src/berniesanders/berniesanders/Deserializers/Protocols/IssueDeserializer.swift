import Foundation

public protocol IssueDeserializer {
    func deserializeIssues(jsonDictionary: NSDictionary) -> Array<Issue>
}
