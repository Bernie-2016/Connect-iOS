import Foundation
import CBGPromise

enum IssueRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
}

typealias IssuesPromise = Promise<[Issue], IssueRepositoryError>
typealias IssuesFuture = Future<[Issue], IssueRepositoryError>

protocol IssueRepository {
    func fetchIssues() -> IssuesFuture
}
