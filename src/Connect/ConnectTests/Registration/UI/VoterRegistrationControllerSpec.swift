import Quick
import Nimble

@testable import Connect

class VoterRegistrationControllerSpec: QuickSpec {
    override func spec() {
        describe("VoterRegistrationController") {
            var subject: VoterRegistrationController!
            var upcomingVoterRegistrationUseCase: FakeUpcomingVoterRegistrationUseCase!
            var tabBarItemStylist: FakeTabBarItemStylist!
            var urlOpener: FakeURLOpener!
            let theme = VoterRegistrationFakeTheme()

            beforeEach {
                upcomingVoterRegistrationUseCase = FakeUpcomingVoterRegistrationUseCase()
                tabBarItemStylist = FakeTabBarItemStylist()
                urlOpener = FakeURLOpener()

                subject = VoterRegistrationController(
                upcomingVoterRegistrationUseCase: upcomingVoterRegistrationUseCase,
                        tabBarItemStylist: tabBarItemStylist,
                        urlOpener: urlOpener,
                        theme: theme
                )
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(tabBarItemStylist.lastReceivedTabBarItem) === subject.tabBarItem

                expect(tabBarItemStylist.lastReceivedTabBarImage) == UIImage(named: "registerTabBarIconInactive")
                expect(tabBarItemStylist.lastReceivedTabBarSelectedImage) == UIImage(named: "registerTabBarIcon")
            }

            describe("when the view loads") {
                it("asks the upcoming voter registation use case for new registration details") {
                    expect(upcomingVoterRegistrationUseCase.didFetchUpcomingVoterRegistrations) == false

                    subject.view.layoutSubviews()

                    expect(upcomingVoterRegistrationUseCase.didFetchUpcomingVoterRegistrations) == true
                }

                it("has the correct subviews") {
                    subject.view.layoutSubviews();

                    expect(subject.view.subviews.count).to(equal(2))
                    expect(subject.view.subviews).to(contain(subject.activityIndicatorView))
                    expect(subject.view.subviews).to(contain(subject.tableView))
                }

                it("shows the spinner") {
                    subject.view.layoutSubviews();

                    expect(subject.activityIndicatorView.hidden) == false
                }

                it("hides the table view") {
                    subject.view.layoutSubviews();

                    expect(subject.tableView.hidden) == true
                }

                it("styles the screen with the theme") {
                    subject.view.layoutSubviews();

                    expect(subject.view.backgroundColor) == UIColor.yellowColor()
                    expect(subject.tableView.backgroundColor) == UIColor.yellowColor()
                }

                describe("when the use case returns voter registation info") {
                    beforeEach {
                        subject.view.layoutSubviews()
                    }

                    it("hides the spinner") {
                        upcomingVoterRegistrationUseCase.lastCompletionHandler!([])

                        expect(subject.activityIndicatorView.hidden) == true
                    }

                    it("shows the table view") {
                        upcomingVoterRegistrationUseCase.lastCompletionHandler!([])

                        expect(subject.tableView.hidden) == false

                    }

                    it("reloads the table view") {
                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 0

                        let info = [TestUtils.voterRegistrationInfo(), TestUtils.voterRegistrationInfo()]
                        upcomingVoterRegistrationUseCase.lastCompletionHandler!(info)

                        expect(subject.tableView.dataSource?.tableView(subject.tableView, numberOfRowsInSection: 0)) == 2

                    }

                    describe("table content") {
                        beforeEach {
                            let info = [
                                    VoterRegistrationInfo(stateName: "state a", url: NSURL(string: "https://example.com/a")!),
                                    VoterRegistrationInfo(stateName: "state b", url: NSURL(string: "https://example.com/b")!)
                            ]

                            upcomingVoterRegistrationUseCase.lastCompletionHandler!(info)
                        }

                        it("it has a table section header") {
                            let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as! RegistrationHeaderView

                            expect(header).toNot(beNil())
                            expect(header.label.text).to(contain("you must be registered"))
                        }

                        it("styles the table section header with the theme") {
                            let header = subject.tableView.delegate?.tableView!(subject.tableView, viewForHeaderInSection: 0) as! RegistrationHeaderView

                            expect(header.contentView.backgroundColor) == UIColor.purpleColor()
                            expect(header.label.textColor) == UIColor.redColor()
                            expect(header.label.font) == UIFont.systemFontOfSize(111)
                        }

                        it("uses the state name of the voter info for the row title") {
                            let cellA = subject.tableView.dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? SimpleTableViewCell

                            expect(cellA?.titleLabel.text) == "state a"

                            let cellB = subject.tableView.dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? SimpleTableViewCell

                            expect(cellB?.titleLabel.text) == "state b"
                        }

                        it("styles the cells with the theme") {
                            let cell = subject.tableView.dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? SimpleTableViewCell

                            expect(cell?.disclosureIndicatorView.color).to(equal(UIColor.magentaColor()))
                            expect(cell?.titleLabel.font).to(equal(UIFont.systemFontOfSize(222)))
                            expect(cell?.titleLabel.textColor).to(equal(UIColor.orangeColor()))
                        }

                        describe("tapping on a row") {
                            it("opens the URL of the voter info in safari") {
                                subject.tableView.delegate?.tableView!(subject.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                                expect(urlOpener.lastOpenedURL) == NSURL(string: "https://example.com/a")!
                            }
                        }
                    }
                }
            }
        }
    }
}

private class FakeUpcomingVoterRegistrationUseCase: UpcomingVoterRegistrationUseCase {
    var didFetchUpcomingVoterRegistrations = false
    var lastCompletionHandler: UpcomingVoterRegistrationsCompletionHandler?

    private func fetchUpcomingVoterRegistrations(completionHandler: UpcomingVoterRegistrationsCompletionHandler) {
        lastCompletionHandler = completionHandler
        didFetchUpcomingVoterRegistrations = true
    }
}

private class VoterRegistrationFakeTheme: FakeTheme {
    private override func registrationHeaderFont() -> UIFont {
        return UIFont.systemFontOfSize(111)
    }

    private override func registrationHeaderTextColor() -> UIColor {
        return UIColor.redColor()
    }

    private override func registrationHeaderBackgroundColor() -> UIColor {
        return UIColor.purpleColor()
    }

    private override func defaultBackgroundColor() -> UIColor {
        return UIColor.yellowColor()
    }

    private override func defaultDisclosureColor() -> UIColor {
        return UIColor.magentaColor()
    }

    private override func registrationStateFont() -> UIFont { return UIFont.systemFontOfSize(222) }
    private override func registrationStateTextColor() -> UIColor { return UIColor.orangeColor() }
}
