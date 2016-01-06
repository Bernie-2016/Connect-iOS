import Foundation
import WebImage

class ConcreteNewsFeedItemControllerProvider: NewsFeedItemControllerProvider {
    private let timeIntervalFormatter: TimeIntervalFormatter
    private let imageRepository: ImageRepository
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let urlAttributionPresenter: URLAttributionPresenter
    private let urlProvider: URLProvider
    private let theme: Theme

    init(timeIntervalFormatter: TimeIntervalFormatter,
        imageRepository: ImageRepository,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlAttributionPresenter: URLAttributionPresenter,
        urlProvider: URLProvider,
        theme: Theme) {
        self.timeIntervalFormatter = timeIntervalFormatter
        self.imageRepository = imageRepository
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlProvider = urlProvider
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme
    }

    func provideInstanceWithNewsFeedItem(newsFeedItem: NewsFeedItem) -> UIViewController {
        if newsFeedItem is NewsArticle {
            let newsArticle: NewsArticle! = newsFeedItem as? NewsArticle
            return NewsArticleController(
                newsArticle: newsArticle,
                imageRepository: self.imageRepository,
                timeIntervalFormatter: self.timeIntervalFormatter,
                analyticsService: self.analyticsService,
                urlOpener: self.urlOpener,
                urlAttributionPresenter: self.urlAttributionPresenter,
                theme: self.theme)
        } else if newsFeedItem is Video {
            let video: Video! = newsFeedItem as? Video
            return VideoController(video: video,
                imageRepository: imageRepository,
                timeIntervalFormatter: timeIntervalFormatter,
                urlProvider: urlProvider,
                urlOpener: urlOpener,
                urlAttributionPresenter: urlAttributionPresenter,
                analyticsService: analyticsService,
                theme: theme)
        }

        fatalError("Unknown news feed item")
    }
}
