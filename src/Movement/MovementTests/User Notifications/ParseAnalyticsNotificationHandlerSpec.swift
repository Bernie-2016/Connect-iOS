import Quick
import Nimble
import Parse

@testable import Movement

class FakePFAnalyticsProxy: PFAnalyticsProxy {
    var lastReceivedUserInfo: NotificationUserInfo!

    override func trackAppOpenedWithRemoteNotificationPayload(userInfo: NotificationUserInfo) {
        lastReceivedUserInfo = userInfo
    }
}

class ParseAnalyticsNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("ParseAnalyticsNotificationHandler") {
            var subject: UserNotificationHandler!
            var pfAnalyticsProxy: FakePFAnalyticsProxy!

            beforeEach {
                pfAnalyticsProxy = FakePFAnalyticsProxy()
                subject = ParseAnalyticsNotificationHandler(pfAnalyticsProxy: pfAnalyticsProxy)
            }

            describe("handling a notification") {
                it("tracks the notification via PFAnalytics") {
                    let notification = ["hey": "yo"]
                    subject.handleRemoteNotification(notification)

                    expect(pfAnalyticsProxy.lastReceivedUserInfo["hey"] as? String).to(equal(notification["hey"]))
                }
            }
        }
    }
}
