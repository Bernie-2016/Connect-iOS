import Foundation
import WebImage

class ConcreteNewsFeedItemControllerProvider: NewsFeedItemControllerProvider {
    private let timeIntervalFormatter: TimeIntervalFormatter
    private let markdownConverter: MarkdownConverter
    private let imageService: ImageService
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlProvider: URLProvider
    private let theme: Theme

    init(timeIntervalFormatter: TimeIntervalFormatter,
        imageService: ImageService,
        markdownConverter: MarkdownConverter,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlProvider: URLProvider,
        theme: Theme) {
        self.timeIntervalFormatter = timeIntervalFormatter
        self.markdownConverter = markdownConverter
        self.imageService = imageService
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlProvider = urlProvider
        self.theme = theme
    }

    func provideInstanceWithNewsFeedItem(newsFeedItem: NewsFeedItem) -> UIViewController {
        if newsFeedItem is NewsArticle {
            let newsArticle: NewsArticle! = newsFeedItem as? NewsArticle

            return NewsArticleController(
                newsArticle: newsArticle,
                markdownConverter: markdownConverter,
                imageService: self.imageService,
                timeIntervalFormatter: self.timeIntervalFormatter,
                analyticsService: self.analyticsService,
                urlOpener: self.urlOpener,
                theme: self.theme)
        } else if newsFeedItem is Video {
            let video: Video! = newsFeedItem as? Video
            return VideoController(video: video,
                timeIntervalFormatter: timeIntervalFormatter,
                urlProvider: urlProvider,
                urlOpener: urlOpener,
                analyticsService: analyticsService,
                theme: theme)
        }

        fatalError("Unknown news feed item")
    }
}
