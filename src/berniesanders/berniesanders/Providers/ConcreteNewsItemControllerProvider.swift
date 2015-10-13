import Foundation
import WebImage

class ConcreteNewsItemControllerProvider: NewsItemControllerProvider {
    private let dateFormatter : NSDateFormatter
    private let imageRepository : ImageRepository
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlAttributionPresenter: URLAttributionPresenter
    private let theme: Theme

    init(dateFormatter: NSDateFormatter, imageRepository: ImageRepository, analyticsService: AnalyticsService, urlOpener: URLOpener, urlAttributionPresenter: URLAttributionPresenter, theme: Theme) {
        self.dateFormatter = dateFormatter
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
            dateFormatter: self.dateFormatter,
            analyticsService: self.analyticsService,
            urlOpener: self.urlOpener,
            urlAttributionPresenter: self.urlAttributionPresenter,
            theme: self.theme)
    }
}
