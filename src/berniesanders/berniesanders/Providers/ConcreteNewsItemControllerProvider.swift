import Foundation
import WebImage

public class ConcreteNewsItemControllerProvider : NewsItemControllerProvider {
    var dateFormatter : NSDateFormatter!
    var imageRepository : ImageRepository!
    var analyticsService: AnalyticsService!
    let urlOpener: URLOpener!
    let urlAttributionPresenter: URLAttributionPresenter!
    var theme : Theme!

    public init(dateFormatter: NSDateFormatter, imageRepository: ImageRepository, analyticsService: AnalyticsService, urlOpener: URLOpener, urlAttributionPresenter: URLAttributionPresenter, theme: Theme) {
        self.dateFormatter = dateFormatter
        self.imageRepository = imageRepository
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme
    }
    
    public func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController {
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