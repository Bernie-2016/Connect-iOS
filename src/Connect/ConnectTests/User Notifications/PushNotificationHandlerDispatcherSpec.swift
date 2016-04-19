import Quick
import Nimble

@testable import Connect

class PushNotificationHandlerDispatcherSpec: QuickSpec {
    override func spec() {
        describe("PushNotificationHandlerDispatcher") {
            var subject: PushNotificationHandlerDispatcher!
            var handlerA: FakeRemoteNotificationHandler!
            var handlerB: FakeRemoteNotificationHandler!

            beforeEach {
                handlerA = FakeRemoteNotificationHandler()
                handlerB = FakeRemoteNotificationHandler()

                subject = PushNotificationHandlerDispatcher(handlers: [handlerA, handlerB])
            }

            describe("dispatching push notifications") {
                it("forwards the push notification to all the configured handlers") {
                    let userInfo: NotificationUserInfo = ["wat": "yo"]

                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(handlerA.lastReceivedUserInfo["wat"]).to(beIdenticalTo(userInfo["wat"]))
                    expect(handlerB.lastReceivedUserInfo["wat"]).to(beIdenticalTo(userInfo["wat"]))
                }
            }
        }
    }
}

