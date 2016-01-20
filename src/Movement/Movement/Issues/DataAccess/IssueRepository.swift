import Foundation

enum IssueRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
}

protocol IssueRepository {
    func fetchIssues(completion: (Array<Issue>) -> Void, error: (IssueRepositoryError) -> Void)
}
