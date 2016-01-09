import Foundation

class ConcreteIssueControllerProvider: IssueControllerProvider {
    private let imageService: ImageService
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlAttributionPresenter: URLAttributionPresenter
    private let theme: Theme

    init(imageService: ImageService,
         analyticsService: AnalyticsService,
         urlOpener: URLOpener,
         urlAttributionPresenter: URLAttributionPresenter,
         theme: Theme) {
        self.imageService = imageService
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme
    }

    func provideInstanceWithIssue(issue: Issue) -> IssueController {
        return IssueController(issue: issue,
                               imageService: imageService,
                               analyticsService: analyticsService,
                               urlOpener: urlOpener,
                               urlAttributionPresenter:
                               urlAttributionPresenter,
                               theme: theme)
    }
}
