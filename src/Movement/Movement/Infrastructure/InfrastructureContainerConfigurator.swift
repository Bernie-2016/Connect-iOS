import Swinject
import WebImage

class InfrastructureContainerConfigurator: ContainerConfigurator {
    // swiftlint:disable function_body_length
    static func configureContainer(container: Container) {
        container.register(URLProvider.self) { resolver in
            let sharknadoBaseURL = NSURL(string: "https://elasticsearch.movementapp.io")!
            return ConcreteURLProvider(sharknadoBaseURL: sharknadoBaseURL)
        }.inObjectScope(.Container)

        container.register(URLOpener.self) { resolver in
            return URLOpener()
        }.inObjectScope(.Container)

        container.register(ApplicationSettingsRepository.self) { resolver in
            return ConcreteApplicationSettingsRepository(
                userDefaults: resolver.resolve(NSUserDefaults.self)!
            )
        }.inObjectScope(.Container)

        container.register(APIKeyProvider.self) { _ in
            return APIKeyProvider()
        }.inObjectScope(.Container)

        container.register(AnalyticsService.self) { resolver in
            return ConcreteAnalyticsService(
                applicationSettingsRepository: resolver.resolve(ApplicationSettingsRepository.self)!,
                apiKeyProvider: resolver.resolve(APIKeyProvider.self)!
            )
        }.inObjectScope(.Container)

        container.register(NSJSONSerializationProvider.self) { _ in
            return NSJSONSerializationProvider()
        }.inObjectScope(.Container)

        container.register(JSONClient.self) { resolver in
            return ConcreteJSONClient(
                urlSession: resolver.resolve(NSURLSession.self, name: "shared")!,
                jsonSerializationProvider: resolver.resolve(NSJSONSerializationProvider.self)!
            )
        }.inObjectScope(.Container)

        container.register(DateProvider.self) { _ in
            return ConcreteDateProvider()
        }.inObjectScope(.Container)

        container.register(APIKeyProvider.self) { resolver in
                return APIKeyProvider()
        }.inObjectScope(.Container)

        container.register(ImageRepository.self) { resolver in
          return ConcreteImageRepository(webImageManager: resolver.resolve(SDWebImageManager.self)!)
        }.inObjectScope(.Container)

        container.register(ImageService.self) { resolver in
                return BackgroundImageService(
                    imageRepository: resolver.resolve(ImageRepository.self)!,
                    workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                    resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!
            )
        }.inObjectScope(.Container)

        container.register(PFAnalyticsProxy.self) { _ in
            return PFAnalyticsProxy()
        }
    }
    // swiftlint:enable function_body_length
}
