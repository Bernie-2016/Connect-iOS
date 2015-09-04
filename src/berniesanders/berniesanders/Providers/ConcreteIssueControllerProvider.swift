import Foundation

public class ConcreteIssueControllerProvider : IssueControllerProvider {
    let imageRepository: ImageRepository!
    let theme : Theme!
    
    public init(imageRepository: ImageRepository, theme: Theme) {
        self.imageRepository = imageRepository
        self.theme = theme
    }
    
    public func provideInstanceWithIssue(issue: Issue) -> IssueController {
        return IssueController(issue: issue, imageRepository: self.imageRepository, theme: self.theme)
    }
}
