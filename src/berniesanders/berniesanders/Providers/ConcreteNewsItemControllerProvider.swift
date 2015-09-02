import Foundation
import WebImage

public class ConcreteNewsItemControllerProvider : NewsItemControllerProvider {
    var dateFormatter : NSDateFormatter!
    var imageRepository : ImageRepository!
    var theme : Theme!

    public init(dateFormatter: NSDateFormatter, imageRepository: ImageRepository, theme: Theme) {
        self.dateFormatter = dateFormatter
        self.imageRepository = imageRepository
        self.theme = theme
    }
    
    public func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController {
        return NewsItemController(newsItem: newsItem, dateFormatter: self.dateFormatter, imageRepository: self.imageRepository, theme: self.theme)
    }
}