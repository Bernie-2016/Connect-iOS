import Foundation
import WebImage

class ConcreteNewsItemControllerProvider: NewsItemControllerProvider {
    private let humanTimeIntervalFormatter: HumanTimeIntervalFormatter
    private let imageRepository: ImageRepository
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlAttributionPresenter: URLAttributionPresenter
    private let theme: Theme

    init(humanTimeIntervalFormatter: HumanTimeIntervalFormatter, imageRepository: ImageRepository, analyticsService: AnalyticsService, urlOpener: URLOpener, urlAttributionPresenter: URLAttributionPresenter, theme: Theme) {
        self.humanTimeIntervalFormatter = humanTimeIntervalFormatter
        self.imageRepository = imageRepository
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme
    }

    func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController {
        return NewsItemController(
            newsItem: newsItem,
            imageRepository: self.imageRepository,
            humanTimeIntervalFormatter: self.humanTimeIntervalFormatter,
            analyticsService: self.analyticsService,
            urlOpener: self.urlOpener,
            urlAttributionPresenter: self.urlAttributionPresenter,
            theme: self.theme)
    }
}
