import Foundation


class ConcreteIssueRepository : IssueRepository {
    func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        var issueA = Issue(title: "Get money out of politics")
        var issueB = Issue(title: "Universal Healthcare")
        
        completion([issueA, issueB])
    }
}