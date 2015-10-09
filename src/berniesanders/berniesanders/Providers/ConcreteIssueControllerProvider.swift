import Foundation

public class ConcreteIssueControllerProvider: IssueControllerProvider {
    private let imageRepository: ImageRepository
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlAttributionPresenter: URLAttributionPresenter
    private let theme : Theme
    
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
