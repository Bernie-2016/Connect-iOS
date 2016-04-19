import Quick
import Nimble
import Parse

@testable import Connect

class FakePFAnalyticsProxy: PFAnalyticsProxy {
    var lastReceivedUserInfo: NotificationUserInfo!

    override func trackAppOpenedWithRemoteNotificationPayload(userInfo: NotificationUserInfo) {
        lastReceivedUserInfo = userInfo
    }
}

class ParseAnalyticsNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("ParseAnalyticsNotificationHandler") {
            var subject: RemoteNotificationHandler!
            var pfAnalyticsProxy: FakePFAnalyticsProxy!

            beforeEach {
                pfAnalyticsProxy = FakePFAnalyticsProxy()
                subject = ParseAnalyticsNotificationHandler(pfAnalyticsProxy: pfAnalyticsProxy)
            }

            describe("handling a notification") {
                it("tracks the notification via PFAnalytics") {
                    let userInfo = ["hey": "yo"]
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(pfAnalyticsProxy.lastReceivedUserInfo["hey"] as? String).to(equal(userInfo["hey"]))
                }

                it("does not call the completion handler") {
                    let userInfo = ["hey": "yo"]
                    var receivedFetchResult: UIBackgroundFetchResult?

                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }

                    expect(receivedFetchResult).to(beNil())
                }
            }
        }
    }
}
