import Foundation

class ConcreteIssueControllerProvider : IssueControllerProvider {
    func provideInstanceWithIssue(issue: Issue) -> IssueController {
        return IssueController(issue: Issue(title: "not implemented yet"))
    }
}
