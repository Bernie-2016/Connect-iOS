import Foundation

public class ConcreteIssueControllerProvider : IssueControllerProvider {
    let imageRepository: ImageRepository!
    let analyticsService: AnalyticsService!
    let theme : Theme!
    
    public init(imageRepository: ImageRepository, analyticsService: AnalyticsService, theme: Theme) {
        self.imageRepository = imageRepository
        self.analyticsService = analyticsService
        self.theme = theme
    }
    
    public func provideInstanceWithIssue(issue: Issue) -> IssueController {
        return IssueController(issue: issue, imageRepository: self.imageRepository, analyticsService: self.analyticsService, theme: self.theme)
    }
}
