import Foundation
import WebImage

public class ConcreteNewsItemControllerProvider : NewsItemControllerProvider {
    var dateFormatter : NSDateFormatter!
    var imageRepository : ImageRepository!
    var analyticsService: AnalyticsService!
    var theme : Theme!

    public init(dateFormatter: NSDateFormatter, imageRepository: ImageRepository, analyticsService: AnalyticsService, theme: Theme) {
        self.dateFormatter = dateFormatter
        self.imageRepository = imageRepository
        self.analyticsService = analyticsService
        self.theme = theme
    }
    
    public func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController {
        return NewsItemController(
            newsItem: newsItem,
            imageRepository: self.imageRepository,
            dateFormatter: self.dateFormatter,
            analyticsService: self.analyticsService,
            theme: self.theme)
    }
}