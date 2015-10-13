import Foundation

protocol IssueDeserializer {
    func deserializeIssues(jsonDictionary: NSDictionary) -> Array<Issue>
}
