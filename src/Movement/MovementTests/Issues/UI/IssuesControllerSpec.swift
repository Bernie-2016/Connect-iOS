@testable import Movement
import Quick
import Nimble
import UIKit

class IssuesControllerSpec: QuickSpec {
    override func spec() {
        describe("IssuesController") {
            var subject: IssuesController!
            var issueService: FakeIssueService!
            var issueControllerProvider: FakeIssueControllerProvider!
            var navigationController: UINavigationController!
            var analyticsService: FakeAnalyticsService!
            var tabBarItemStylist: FakeTabBarItemStylist!


            beforeEach {
                issueService = FakeIssueService()
                issueControllerProvider = FakeIssueControllerProvider()
                navigationController = UINavigationController()
                tabBarItemStylist = FakeTabBarItemStylist()
                analyticsService = FakeAnalyticsService()

                subject = IssuesController(
                    issueService: issueService,
                    issueControllerProvider: issueControllerProvider,
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    theme: IssuesFakeTheme()
                )

                navigationController.pushViewController(subject, animated: false)
                subject.view.layoutSubviews()
            }

            it("has the correct tab bar title") {
                expect(subject.title).to(equal("Issues"))
            }

            it("has the correct navigation item title") {
                expect(subject.navigationItem.title).to(equal("Issues"))
            }

            it("should set the back bar button item title correctly") {
                expect(subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "issuesTabBarIconInactive")))
                expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "issuesTabBarIcon")))
            }

            it("initially hides the table view, and shows the loading spinner") {
                expect(subject.tableView.hidden).to(equal(true));
                expect(subject.loadingIndicatorView.isAnimating()).to(equal(true))
            }

            it("has the page components as subviews") {
                let subViews = subject.view.subviews

                expect(subViews.contains(subject.tableView)).to(beTrue())
                expect(subViews.contains(subject.loadingIndicatorView)).to(beTrue())
            }

            it("sets the spinner up to hide when stopped") {
                expect(subject.loadingIndicatorView.hidesWhenStopped).to(equal(true))
            }

            it("styles the views with the theme") {
                expect(subject.tableView.backgroundColor).to(equal(UIColor.orangeColor()))
                expect(subject.loadingIndicatorView.color).to(equal(UIColor.greenColor()))
            }

            describe("when the controller appears") {
                beforeEach {
                    subject.view.layoutIfNeeded()
                    subject.viewWillAppear(false)
                }

                it("has an empty table") {
                    expect(subject.tableView.numberOfSections).to(equal(1))
                    expect(subject.tableView.numberOfRowsInSection(0)).to(equal(0))
                }

                it("asks the issue service for some news") {
                    expect(issueService.fetchIssuesCalled).to(beTrue())
                }


                describe("when the issue repository returns some issues") {
                    beforeEach {
                        let issueA = Issue(title: "Big Money in Little DC", body: "body", imageURL: NSURL(string: "http://a.com")!, url: NSURL(string: "http://b.com")!)
                        let issueB = Issue(title: "Long Live The NHS", body: "body", imageURL: NSURL(string: "http://c.com")!, url: NSURL(string: "http://d.com")!)

                        issueService.lastReturnedPromise!.resolve([issueA, issueB])
                    }

                    it("shows the table view, and stops the loading spinner") {
                        expect(subject.tableView.hidden).to(equal(false));
                        expect(subject.loadingIndicatorView.isAnimating()).to(equal(false))
                    }

                    it("shows the issues in the table") {
                        expect(subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                        let cellA = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IssueTableViewCell
                        expect(cellA.titleLabel.text).to(equal("Big Money in Little DC"))

                        let cellB = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! IssueTableViewCell
                        expect(cellB.titleLabel.text).to(equal("Long Live The NHS"))
                    }

                    it("styles the items in the table") {
                        let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IssueTableViewCell

                        expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                        expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                        expect(cell.backgroundColor).to(equal(UIColor.redColor()))
                    }
                }

                context("when the repository encounters an error fetching issues") {
                    let expectedError = IssueRepositoryError.InvalidJSON(jsonObject: "wat")

                    beforeEach {
                        issueService.lastReturnedPromise!.reject(expectedError)
                    }

                    it("logs that error to the analytics service") {
                        switch(analyticsService.lastError  as! IssueRepositoryError) {
                        case .InvalidJSON(let jsonObject):
                            expect((jsonObject as! String)).to(equal("wat"))
                        default:
                            fail("unexpected error type")
                        }
                        expect(analyticsService.lastErrorContext).to(equal("Failed to load issues"))
                    }

                    it("shows the an error in the table") {
                        expect(subject.tableView.numberOfSections).to(equal(1))
                        expect(subject.tableView.numberOfRowsInSection(0)).to(equal(1))

                        let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                        expect(cell.textLabel!.text).to(equal("Oops! Sorry, we couldn't load any issues."))
                    }

                    it("styles the items in the table") {
                        let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                        expect(cell.textLabel!.textColor).to(equal(UIColor.magentaColor()))
                        expect(cell.textLabel!.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    }

                    context("and then the user refreshes the issues screen") {
                        beforeEach {
                            subject.viewWillAppear(false)
                        }

                        describe("when the issues repository returns some issues") {
                            beforeEach {
                                let issueA = Issue(title: "Big Money in Little DC", body: "body", imageURL: NSURL(string: "http://a.com")!, url: NSURL(string: "http://b.com")!)
                                let issueB = Issue(title: "Long Live The NHS", body: "body", imageURL: NSURL(string: "http://c.com")!, url: NSURL(string: "http://d.com")!)

                                issueService.lastReturnedPromise!.resolve([issueA, issueB])
                            }


                            it("shows the issues in the table") {
                                expect(subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                                let cellA = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IssueTableViewCell
                                expect(cellA.titleLabel.text).to(equal("Big Money in Little DC"))

                                let cellB = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! IssueTableViewCell
                                expect(cellB.titleLabel.text).to(equal("Long Live The NHS"))
                            }
                        }
                    }
                }

                describe("Tapping on an issue") {
                    let expectedIssue = TestUtils.issue()

                    beforeEach {
                        subject.view.layoutIfNeeded()
                        subject.viewWillAppear(false)
                        let otherIssue = TestUtils.issue()

                        let issues = [otherIssue, expectedIssue]

                        issueService.lastReturnedPromise!.resolve(issues)

                        let tableView = subject.tableView
                        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                        tableView.delegate?.tableView!(tableView, didSelectRowAtIndexPath: indexPath)

                    }

                    it("tracks the content view with the analytics service") {
                        expect(analyticsService.lastContentViewName).to(equal(expectedIssue.title))
                        expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Issue))
                        expect(analyticsService.lastContentViewID).to(equal(expectedIssue.url.absoluteString))
                    }


                    it("should push a correctly configured issue controller onto the nav stack") {
                        expect(issueControllerProvider.lastIssue).to(beIdenticalTo(expectedIssue))
                        expect(subject.navigationController!.topViewController).to(beIdenticalTo(issueControllerProvider.controller))
                    }

                    describe("and the view is shown again") {
                        it("deselects the selected table row") {
                            subject.viewWillAppear(false)

                            expect(subject.tableView.indexPathForSelectedRow).to(beNil())
                        }
                    }
                }
            }
        }
    }
}

private class IssuesFakeTheme: FakeTheme {
    override func issuesFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func issuesFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func defaultSpinnerColor() -> UIColor {
        return UIColor.greenColor()
    }

    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }

    override func defaultTableCellBackgroundColor() -> UIColor {
        return UIColor.redColor()
    }
}

private class FakeIssueControllerProvider: IssueControllerProvider {
    let controller = IssueController(issue: TestUtils.issue(), imageService: FakeImageService(), analyticsService: FakeAnalyticsService(),
        urlOpener: FakeURLOpener(), urlAttributionPresenter: FakeURLAttributionPresenter(), theme: FakeTheme())
    var lastIssue: Issue?

    func provideInstanceWithIssue(issue: Issue) -> IssueController {
        self.lastIssue = issue;
        return self.controller
    }
}

private class FakeIssueService: IssueService {
    var fetchIssuesCalled = false
    var lastReturnedPromise: IssuesPromise!


    private func fetchIssues() -> IssuesFuture {
        fetchIssuesCalled = true
        lastReturnedPromise = IssuesPromise()
        return lastReturnedPromise.future
    }
}
