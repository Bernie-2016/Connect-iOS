import Foundation

public class ConcreteIssueControllerProvider: IssueControllerProvider {
    let imageRepository: ImageRepository
    let analyticsService: AnalyticsService
    let urlOpener: URLOpener
    let urlAttributionPresenter: URLAttributionPresenter
    let theme : Theme
    
    public init(imageRepository: ImageRepository, analyticsService: AnalyticsService, urlOpener: URLOpener, urlAttributionPresenter: URLAttributionPresenter, theme: Theme) {
        self.imageRepository = imageRepository
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme
    }
    
    public func provideInstanceWithIssue(issue: Issue) -> IssueController {
        return IssueController(issue: issue, imageRepository: self.imageRepository, analyticsService: self.analyticsService, urlOpener: self.urlOpener, urlAttributionPresenter: self.urlAttributionPresenter, theme: self.theme)
    }
}
