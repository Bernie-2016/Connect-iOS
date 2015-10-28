import UIKit
import Quick
import Nimble
@testable import berniesanders

class SettingsFakeURLProvider: FakeURLProvider {
    override func donateFormURL() -> NSURL! {
        return NSURL(string: "https://example.com/donate")!
    }
}

class SettingsFakeTheme: FakeTheme {
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }

    override func settingsTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }

    override func settingsTitleColor() -> UIColor {
        return UIColor.purpleColor()
    }

    override func settingsDonateButtonTextColor() -> UIColor {
        return UIColor.greenColor()
    }

    override func settingsDonateButtonFont() -> UIFont {
        return UIFont.systemFontOfSize(222)
    }

    override func settingsDonateButtonColor() -> UIColor {
        return UIColor.magentaColor()
    }
}

class FakeSettingsController : UIViewController {
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SettingsControllerSpec : QuickSpec {
    var subject: SettingsController!
    var urlOpener: FakeURLOpener!
    let urlProvider = SettingsFakeURLProvider()
    var analyticsService: FakeAnalyticsService!
    var tabBarItemStylist: FakeTabBarItemStylist!
    let theme = SettingsFakeTheme()

    let regularController = FakeSettingsController(title: "Regular Controller")

    let flossController = TestUtils.privacyPolicyController()
    var navigationController: UINavigationController!

    override func spec() {
        describe("SettingsController") {
            beforeEach {
                self.urlOpener = FakeURLOpener()
                self.analyticsService = FakeAnalyticsService()
                self.tabBarItemStylist = FakeTabBarItemStylist()

                self.subject = SettingsController(tappableControllers: [
                        self.regularController
                    ],
                    urlOpener: self.urlOpener,
                    urlProvider: self.urlProvider,
                    analyticsService: self.analyticsService,
                    tabBarItemStylist: self.tabBarItemStylist,
                    theme: self.theme)

                self.navigationController = UINavigationController()
                self.navigationController.pushViewController(self.subject, animated: false)
            }

            it("has the correct navigation item title") {
                expect(self.subject.navigationItem.title).to(equal("More"))
            }

            it("has the correct tab bar title") {
                expect(self.subject.title).to(equal("More"))
            }

            it("should set the back bar button item title correctly") {
                expect(self.subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }

            it("tracks taps on the back button with the analytics service") {
                self.subject.didMoveToParentViewController(nil)

                expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Back' on Settings"))
                expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
            }

            describe("when the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }

                it("uses the tab bar item stylist to style its tab bar item") {
                    expect(self.tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(self.subject.tabBarItem))

                    expect(self.tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "moreTabBarIconInactive")))
                    expect(self.tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "moreTabBarIcon")))
                }

                it("styles the views according to the theme") {
                    expect(self.subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                }

                it("should have rows in the table") {
                    expect(self.subject.tableView.numberOfSections).to(equal(1))
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))
                }

                it("should style the regular rows using the theme") {
                    let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                    expect(cell.textLabel!.textColor).to(equal(UIColor.purpleColor()))
                    expect(cell.textLabel!.font).to(equal(UIFont.systemFontOfSize(123)))
                }

                it("should style the donate row using the theme") {
                    let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))! as! DonateTableViewCell

                    expect(cell.messageView.textColor).to(equal(UIColor.purpleColor()))
                    expect(cell.messageView.font).to(equal(UIFont.systemFontOfSize(123)))

                    expect(cell.buttonView.backgroundColor).to(equal(UIColor.magentaColor()))
                    expect(cell.buttonView.font).to(equal(UIFont.systemFontOfSize(222)))
                    expect(cell.buttonView.textColor).to(equal(UIColor.greenColor()))
                }

                describe("the table contents") {
                    it("has a regular UITableViewCell row for evey configured 'regular' controller") {
                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                        expect(cell.textLabel!.text).to(equal("Regular Controller"))
                        expect(cell).to(beAnInstanceOf(UITableViewCell.self))
                    }
                    describe("tapping the rows") {
                        it("opens the donate page in safari when the donate row is tapped") {
                            let tableView = self.subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

                            expect(self.urlOpener.lastOpenedURL).to(equal(NSURL(string: "https://example.com/donate")!))
                        }

                        it("should push a correctly configured news item view controller onto the nav stack") {
                            let tableView = self.subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                            expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.regularController))
                        }

                        it("should log a content view with the analytics service") {
                            let tableView = self.subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                            expect(self.analyticsService.lastContentViewName).to(equal("Regular Controller"))
                            expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Settings))
                            expect(self.analyticsService.lastContentViewID).to(equal("Regular Controller"))
                        }
                    }
                }

            }
        }
    }
}
