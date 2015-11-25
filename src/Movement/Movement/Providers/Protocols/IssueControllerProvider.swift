import Foundation


protocol IssueControllerProvider {
    func provideInstanceWithIssue(issue: Issue) -> IssueController
}
