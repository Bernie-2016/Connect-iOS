import Quick
import Nimble

@testable import Connect

class OpenVideoNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("OpenVideoNotificationHandler") {
            var subject: UserNotificationHandler!
            var newsNavigationController: UINavigationController!
            var existingActionController: UIViewController!
            var interstitialController: UIViewController!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!
            var newsFeedItemControllerProvider: FakeNewsFeedItemControllerProvider!
            var videoService: FakeVideoService!

            beforeEach {
                existingActionController = UIViewController()
                newsNavigationController = UINavigationController(rootViewController: existingActionController)
                interstitialController = UIViewController()
                tabBarController = UITabBarController()
                selectedTabController = UIViewController()
                newsFeedItemControllerProvider = FakeNewsFeedItemControllerProvider()
                videoService = FakeVideoService()

                tabBarController.viewControllers = [selectedTabController, newsNavigationController]
                tabBarController.selectedIndex = 0


                subject = OpenVideoNotificationHandler(
                    newsNavigationController: newsNavigationController,
                    interstitialController: interstitialController,
                    tabBarController: tabBarController,
                    newsFeedItemControllerProvider: newsFeedItemControllerProvider,
                    videoService: videoService
                )
            }

            describe("handling a notification that will open a video") {
                let userInfo: NotificationUserInfo = ["action": "openVideo", "identifier": "do-it-naaoow"]

                it("pushes the interstitial controller onto the navigation controller") {
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(interstitialController))
                }

                it("ensures that the navigation controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController).to(beIdenticalTo(newsNavigationController))
                }

                it("asks the video service for a video with that identifier") {
                    subject.handleRemoteNotification(userInfo)

                    expect(videoService.lastReceivedIdentifier).to(equal("do-it-naaoow"))
                }

                context("when the video is returned") {
                    beforeEach { subject.handleRemoteNotification(userInfo) }

                    it("replaces the interstitial controller with a controller configured for the video") {
                        let video = TestUtils.video()
                        videoService.lastReturnedPromise.resolve(video)

                        expect(newsFeedItemControllerProvider.lastNewsFeedItem as? Video) === video

                        let expectedController = newsFeedItemControllerProvider.controller
                        expect(newsNavigationController.topViewController).to(beIdenticalTo(expectedController))
                        expect(newsNavigationController.viewControllers) == [existingActionController, expectedController]
                    }
                }

                context("when the action alert fails to be returned") {
                    beforeEach { subject.handleRemoteNotification(userInfo) }

                    it("it pops the interstitial controller from the navigation controller") {
                        let error = VideoRepositoryError.InvalidJSON(jsonObject: [])
                        videoService.lastReturnedPromise.reject(error)

                        expect(newsNavigationController.topViewController).to(beIdenticalTo(existingActionController))
                    }
                }
            }

            describe("handling a notification that is configured to open a video lacks an identifier") {
                it("does nothing to the video navigation controller") {
                    var userInfo: NotificationUserInfo = ["action": "openVideo"]
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingActionController))

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingActionController))
                }

            }
            describe("handling a notification that is not configured to open a video") {
                it("does nothing to the news navigation controller") {
                    var userInfo: NotificationUserInfo = ["action": "openActionAlert", "identifier": "yoyoyo"]
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingActionController))

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingActionController))
                }
            }
        }
    }
}

private class FakeVideoService: VideoService {
    var lastReturnedPromise: VideoPromise!
    var lastReceivedIdentifier: VideoIdentifier!

    private func fetchVideo(identifier: VideoIdentifier) -> VideoFuture {
        lastReturnedPromise = VideoPromise()

        lastReceivedIdentifier = identifier

        return lastReturnedPromise.future
    }
}
