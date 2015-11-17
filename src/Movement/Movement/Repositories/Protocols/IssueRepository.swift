import Foundation


protocol IssueRepository {
    func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void)
}
