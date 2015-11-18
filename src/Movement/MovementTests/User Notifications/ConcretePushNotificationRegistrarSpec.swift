import Quick
import Nimble
import Parse
@testable import Movement

private class FakePFInstallation: PFInstallation {
    var lastDeviceTokenData: NSData!
    override func setDeviceTokenFromData(deviceTokenData: NSData?) {
        self.lastDeviceTokenData = deviceTokenData
    }

    var saveInBackgroundCalled = false
    override func saveInBackground() -> BFTask {
        self.saveInBackgroundCalled = true
        return BFTask()
    }
}

class ConcretePushNotificationRegistrarSpec: QuickSpec {
    var subject: ConcretePushNotificationRegistrar!
    private var application: FakeApplication!
    private var installation: FakePFInstallation!

    override func spec() {
        describe("ConcretePushNotificationRegistrar") {
            beforeEach {
                FakePFInstallation.registerSubclass() // wtf parse, whyyyy

                self.application = FakeApplication()
                self.installation = FakePFInstallation()

                self.subject = ConcretePushNotificationRegistrar(installation: self.installation)
            }

            describe("Registering for push notifications") {
                it("tells the application to register user notifications with the correct settings") {
                    self.subject.registerForRemoteNotificationsWithApplication(self.application)

                    let expectedTypes = UIUserNotificationType([.Alert, .Badge, .Sound])
                    let expectedSettings = UIUserNotificationSettings(forTypes: expectedTypes, categories: nil)

                    expect(self.application.lastRegisteredUserNotificationSettings).to(equal(expectedSettings))
                }

                it("registers the settings before registering for remote notifications") {
                    self.subject.registerForRemoteNotificationsWithApplication(self.application)

                    expect(self.application.registerForRemoteNotificationsCallIndex).to(beGreaterThan(self.application.registerUserNotificationSettingsCallIndex))
                }

                describe("when registering for remote notifications is successful") {
                    let expectedData = "this is a token".dataUsingEncoding(NSUTF8StringEncoding)!

                    it("sets the device token on the current Parse installation") {
                        self.subject.application(self.application, didRegisterForRemoteNotificationsWithDeviceToken: expectedData)

                        expect(self.installation.lastDeviceTokenData).to(beIdenticalTo(expectedData))
                    }

                    it("tells parse to save in the background") {
                        self.subject.application(self.application, didRegisterForRemoteNotificationsWithDeviceToken: expectedData)

                        expect(self.installation.saveInBackgroundCalled).to(beTrue())
                    }
                }
            }
        }
    }
}
