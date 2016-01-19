import Quick
import Nimble
import Swinject

@testable import Movement

class AppDelegateSpec: QuickSpec {
    override func spec() {
        describe("AppDelegate") {
            var application: UIApplication!
            var subject: AppDelegate!
            var appBootstrapper: FakeAppBootstrapper!
            var pushNotificationRegistrar: FakePushNotificationRegistrar!
            var userNotificationHandler: FakeUserNotificationHandler!
            var container: Container!

            beforeEach {
                appBootstrapper = FakeAppBootstrapper()
                application = FakeUIApplicationProvider.fakeUIApplication()
                pushNotificationRegistrar = FakePushNotificationRegistrar()
                userNotificationHandler = FakeUserNotificationHandler()

                subject = AppDelegate()
                container = Container()

                container.register(AppBootstrapper.self) { _ in return appBootstrapper }
                container.register(PushNotificationRegistrar.self) { _ in return pushNotificationRegistrar }
                container.register(UserNotificationHandler.self) { _ in return userNotificationHandler }

                subject.application(application, willFinishLaunchingWithOptions: nil)
                subject.container = container
            }

            describe("When the application finishes launching") {
                context("Without a push notification") {
                    it("bootstraps the app") {
                        expect(appBootstrapper.bootstrapCalled).to(beFalse())

                        subject.application(application, didFinishLaunchingWithOptions:nil)

                        expect(appBootstrapper.bootstrapCalled).to(beTrue())
                    }
                }

                context("with a push notification") {
                    it("bootstraps the app") {
                        expect(appBootstrapper.bootstrapCalled).to(beFalse())

                        subject.application(application, didFinishLaunchingWithOptions:nil)

                        expect(appBootstrapper.bootstrapCalled).to(beTrue())
                    }

                    it("handles the remote notification") {
                        let expectedNotification: NotificationUserInfo = ["wat": NSUUID().UUIDString]
                        let userInfo = [UIApplicationLaunchOptionsRemoteNotificationKey: expectedNotification]

                        subject.application(application, didFinishLaunchingWithOptions:userInfo)

                        expect(userNotificationHandler.lastReceivedUserInfo["wat"]).to(beIdenticalTo(expectedNotification["wat"]))
                    }
                }
            }

            describe("when the application successfully registers for remote notifications") {
                beforeEach { subject.application(application, didFinishLaunchingWithOptions:nil) }

                it("forwards the device token and application to the registrar") {
                    let expectedToken = "fake-token".dataUsingEncoding(NSUTF8StringEncoding)!
                    subject.application(application, didRegisterForRemoteNotificationsWithDeviceToken: expectedToken)

                    let receivedApplication = pushNotificationRegistrar.lastSuccessfullyRegisteredApplication as! NSObject
                    let expectedApplication = application as NSObject

                    expect(receivedApplication).to(beIdenticalTo(expectedApplication))
                    expect(pushNotificationRegistrar.lastSuccessfullyRegisteredDeviceToken).to(beIdenticalTo(expectedToken))
                }
            }

            describe("when the application fails to register for remote notifications") {
                beforeEach { subject.application(application, didFinishLaunchingWithOptions:nil) }

                it("forwards the error and application to the registrar") {
                    let expectedError = NSError(domain: "somerr", code: 9, userInfo: nil)

                    subject.application(application, didFailToRegisterForRemoteNotificationsWithError: expectedError)

                    let receivedApplication = pushNotificationRegistrar.lastFailedRegistrationApplication as! NSObject
                    let expectedApplication = application as NSObject

                    expect(receivedApplication).to(beIdenticalTo(expectedApplication))

                    expect(pushNotificationRegistrar.lastFailedRegistrationError).to(beIdenticalTo(expectedError))
                }
            }

            describe("when the application receives a remote notification") {
                beforeEach { subject.application(application, didFinishLaunchingWithOptions:nil) }

                it("fowards the notification to the user notification handler") {
                    let expectedNotification: NotificationUserInfo = ["wat": NSUUID().UUIDString]

                    subject.application(application, didReceiveRemoteNotification: expectedNotification)

                    expect(userNotificationHandler.lastReceivedUserInfo["wat"]).to(beIdenticalTo(expectedNotification["wat"]))
                }
            }
        }
    }
}

private class FakeAppBootstrapper: AppBootstrapper {
    var bootstrapCalled = false

    private func bootstrap() {
        bootstrapCalled = true
    }
}
