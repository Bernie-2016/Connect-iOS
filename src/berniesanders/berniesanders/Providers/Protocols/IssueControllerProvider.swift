import Foundation


public protocol IssueControllerProvider {
    func provideInstanceWithIssue(issue: Issue) -> IssueController;
}
