import Swinject

class NewsContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        configureDataAccess(container)
        configureUI(container)
    }

    // swiftlint:disable function_body_length
    private static func configureDataAccess(container: Container) {
        container.register(NewsArticleDeserializer.self) { resolver in
            return ConcreteNewsArticleDeserializer()
            }.inObjectScope(.Container)

        container.register(NewsArticleRepository.self) { resolver in
            return ConcreteNewsArticleRepository(
                urlProvider: resolver.resolve(URLProvider.self)!,
                jsonClient: resolver.resolve(JSONClient.self)!,
                newsArticleDeserializer: resolver.resolve(NewsArticleDeserializer.self)!)
            }.inObjectScope(.Container)

        container.register(NewsArticleService.self) { resolver in
            return BackgroundNewsArticleService(
                newsArticleRepository: resolver.resolve(NewsArticleRepository.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!)
            }.inObjectScope(.Container)

        container.register(VideoDeserializer.self) { resolver in
            return ConcreteVideoDeserializer()
            }.inObjectScope(.Container)

        container.register(VideoRepository.self) { resolver in
            return ConcreteVideoRepository(
                urlProvider: resolver.resolve(URLProvider.self)!,
                jsonClient: resolver.resolve(JSONClient.self)!,
                videoDeserializer: resolver.resolve(VideoDeserializer.self)!
            )
            }.inObjectScope(.Container)

        container.register(NewsFeedService.self) { resolver in
            return BackgroundNewsFeedService(
                newsArticleRepository: resolver.resolve(NewsArticleRepository.self)!,
                videoRepository: resolver.resolve(VideoRepository.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!)
            }.inObjectScope(.Container)
    }

    private static func configureUI(container: Container) {
        container.register(NewsFeedItemControllerProvider.self) { resolver in
            return ConcreteNewsFeedItemControllerProvider(
                timeIntervalFormatter: resolver.resolve(TimeIntervalFormatter.self)!,
                imageService: resolver.resolve(ImageService.self)!,
                markdownConverter: resolver.resolve(MarkdownConverter.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                urlAttributionPresenter: resolver.resolve(URLAttributionPresenter.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(NewsFeedTableViewCellPresenter.self, name: "articles") { resolver in
            return NewsFeedArticlePresenter(
                timeIntervalFormatter: resolver.resolve(TimeIntervalFormatter.self)!,
                imageService: resolver.resolve(ImageService.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(NewsFeedTableViewCellPresenter.self, name: "videos") { resolver in
            return NewsFeedVideoPresenter(
                timeIntervalFormatter: resolver.resolve(TimeIntervalFormatter.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                imageService: resolver.resolve(ImageService.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(NewsFeedTableViewCellPresenter.self, name: "feed") { resolver in
            return ConcreteNewsFeedTableViewCellPresenter(
                articlePresenter: resolver.resolve(NewsFeedTableViewCellPresenter.self, name: "articles")!,
                videoPresenter: resolver.resolve(NewsFeedTableViewCellPresenter.self, name: "videos")!
            )
            }.inObjectScope(.Container)

        container.register(NewsFeedController.self) { resolver in
            return NewsFeedController(
                newsFeedService: resolver.resolve(NewsFeedService.self)!,
                newsFeedItemControllerProvider: resolver.resolve(NewsFeedItemControllerProvider.self)!,
                newsFeedCollectionViewCellPresenter: resolver.resolve(NewsFeedCollectionViewCellPresenter.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!,
                mainQueue: resolver.resolve(NSOperationQueue.self, name: "main")!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(NavigationController.self, name: "news") { resolver in
            let navigationController = resolver.resolve(NavigationController.self)!
            let newsFeedController = resolver.resolve(NewsFeedController.self)!
            navigationController.pushViewController(newsFeedController, animated: false)
            return navigationController
        }

        container.register(NewsFeedCollectionViewCellPresenter.self) { resolver in
            return StockNewsFeedCollectionViewCellPresenter(childPresenters: [])
        }
    }
    // swiftlint:enable function_body_length
}
