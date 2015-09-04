import Foundation

public class ConcreteIssueControllerProvider : IssueControllerProvider {
    let theme : Theme!
    
    public init(theme: Theme) {
            self.theme = theme
    }
    
    public func provideInstanceWithIssue(issue: Issue) -> IssueController {
        return IssueController(issue: issue, theme: self.theme)
    }
}
