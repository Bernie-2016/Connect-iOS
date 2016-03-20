@testable import Connect

class FakeNewsFeedItemControllerProvider: NewsFeedItemControllerProvider {
    let controller = NewsArticleController(newsArticle: TestUtils.newsArticle(),
        markdownConverter: FakeMarkdownConverter(),
        imageService: FakeImageService(),
        timeIntervalFormatter: FakeTimeIntervalFormatter(),
        analyticsService: FakeAnalyticsService(),
        urlOpener: FakeURLOpener(),
        theme: FakeTheme())
    var lastNewsFeedItem: NewsFeedItem?

    func provideInstanceWithNewsFeedItem(newsFeedItem: NewsFeedItem) -> UIViewController {
        self.lastNewsFeedItem = newsFeedItem;
        return self.controller
    }
}
