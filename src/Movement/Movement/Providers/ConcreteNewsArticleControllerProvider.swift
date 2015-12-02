import Foundation
import WebImage

class ConcreteNewsArticleControllerProvider: NewsArticleControllerProvider {
    private let timeIntervalFormatter: TimeIntervalFormatter
    private let imageRepository: ImageRepository
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlAttributionPresenter: URLAttributionPresenter
    private let theme: Theme

    init(timeIntervalFormatter: TimeIntervalFormatter, imageRepository: ImageRepository, analyticsService: AnalyticsService, urlOpener: URLOpener, urlAttributionPresenter: URLAttributionPresenter, theme: Theme) {
        self.timeIntervalFormatter = timeIntervalFormatter
        self.imageRepository = imageRepository
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme
    }

    func provideInstanceWithNewsArticle(newsArticle: NewsArticle) -> NewsArticleController {
        return NewsArticleController(
            newsArticle: newsArticle,
            imageRepository: self.imageRepository,
            timeIntervalFormatter: self.timeIntervalFormatter,
            analyticsService: self.analyticsService,
            urlOpener: self.urlOpener,
            urlAttributionPresenter: self.urlAttributionPresenter,
            theme: self.theme)
    }
}
