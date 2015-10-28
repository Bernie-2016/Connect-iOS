@testable import berniesanders
import Quick
import Nimble
import UIKit

class IssuesFakeTheme : FakeTheme {
    override func issuesFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func issuesFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func defaultSpinnerColor() -> UIColor {
        return UIColor.greenColor()
    }
}

class FakeIssueRepository : berniesanders.IssueRepository {
    var lastCompletionBlock: ((Array<Issue>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchIssuesCalled: Bool = false

    func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        self.fetchIssuesCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class FakeIssueControllerProvider : berniesanders.IssueControllerProvider {
    let controller = IssueController(issue: TestUtils.issue(), imageRepository: FakeImageRepository(), analyticsService: FakeAnalyticsService(),
        urlOpener: FakeURLOpener(), urlAttributionPresenter: FakeURLAttributionPresenter(), theme: FakeTheme())
    var lastIssue: Issue?

    func provideInstanceWithIssue(issue: Issue) -> IssueController {
        self.lastIssue = issue;
        return self.controller
    }
}


class IssuesControllerSpec: QuickSpec {
    var subject: IssuesController!
    var issueRepository: FakeIssueRepository! = FakeIssueRepository()
    var issueControllerProvider = FakeIssueControllerProvider()
    var navigationController: UINavigationController!
    var analyticsService: FakeAnalyticsService!
    var tabBarItemStylist: FakeTabBarItemStylist!

    override func spec() {
        describe("IssuesController") {
            beforeEach {
                self.navigationController = UINavigationController()
                self.tabBarItemStylist = FakeTabBarItemStylist()
                self.analyticsService = FakeAnalyticsService()

                self.subject = IssuesController(
                    issueRepository: self.issueRepository,
                    issueControllerProvider: self.issueControllerProvider,
                    analyticsService: self.analyticsService,
                    tabBarItemStylist: self.tabBarItemStylist,
                    theme: IssuesFakeTheme()
                )

                self.navigationController.pushViewController(self.subject, animated: false)
                self.subject.view.layoutSubviews()
            }

            it("has the correct tab bar title") {
                expect(self.subject.title).to(equal("Issues"))
            }

            it("has the correct navigation item title") {
                expect(self.subject.navigationItem.title).to(equal("Issues"))
            }

            it("should set the back bar button item title correctly") {
                expect(self.subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(self.tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(self.subject.tabBarItem))

                expect(self.tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "issuesTabBarIconInactive")))
                expect(self.tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "issuesTabBarIcon")))
            }

            it("initially hides the table view, and shows the loading spinner") {
                expect(self.subject.tableView.hidden).to(equal(true));
                expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(true))
            }

            it("has the page components as subviews") {
                let subViews = self.subject.view.subviews

                expect(subViews.contains(self.subject.tableView)).to(beTrue())
                expect(subViews.contains(self.subject.loadingIndicatorView)).to(beTrue())
            }

            it("sets the spinner up to hide when stopped") {
                expect(self.subject.loadingIndicatorView.hidesWhenStopped).to(equal(true))
            }

            it("styles the spinner from the theme") {
                expect(self.subject.loadingIndicatorView.color).to(equal(UIColor.greenColor()))
            }

            describe("when the controller appears") {
                beforeEach {
                    self.subject.view.layoutIfNeeded()
                    self.subject.viewWillAppear(false)
                }

                it("has an empty table") {
                    expect(self.subject.tableView.numberOfSections).to(equal(1))
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(0))
                }

                it("asks the issue repository for some news") {
                    expect(self.issueRepository.fetchIssuesCalled).to(beTrue())
                }


                describe("when the issue repository returns some issues") {
                    beforeEach {
                        let issueA = Issue(title: "Big Money in Little DC", body: "body", imageURL: NSURL(string: "http://a.com")!, url: NSURL(string: "http://b.com")!)
                        let issueB = Issue(title: "Long Live The NHS", body: "body", imageURL: NSURL(string: "http://c.com")!, url: NSURL(string: "http://d.com")!)

                        self.issueRepository.lastCompletionBlock!([issueA, issueB])
                    }

                    it("shows the table view, and stops the loading spinner") {
                        self.issueRepository.lastCompletionBlock!([])

                        expect(self.subject.tableView.hidden).to(equal(false));
                        expect(self.subject.loadingIndicatorView.isAnimating()).to(equal(false))
                    }

                    it("shows the issues in the table") {
                        expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                        let cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IssueTableViewCell
                        expect(cellA.titleLabel.text).to(equal("Big Money in Little DC"))

                        let cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! IssueTableViewCell
                        expect(cellB.titleLabel.text).to(equal("Long Live The NHS"))
                    }

                    it("styles the items in the table") {
                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IssueTableViewCell

                        expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                        expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    }
                }

                context("when the repository encounters an error fetching issues") {
                    let expectedError = NSError(domain: "some error", code: 666, userInfo: nil)

                    beforeEach {
                        self.issueRepository.lastErrorBlock!(expectedError)
                    }

                    it("logs that error to the analytics service") {
                        expect(self.analyticsService.lastError).to(beIdenticalTo(expectedError))
                        expect(self.analyticsService.lastErrorContext).to(equal("Failed to load issues"))
                    }

                    it("shows the an error in the table") {
                        expect(self.subject.tableView.numberOfSections).to(equal(1))
                        expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(1))

                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                        expect(cell.textLabel!.text).to(equal("Oops! Sorry, we couldn't load any issues."))
                    }

                    it("styles the items in the table") {
                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                        expect(cell.textLabel!.textColor).to(equal(UIColor.magentaColor()))
                        expect(cell.textLabel!.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    }

                    context("and then the user refreshes the issues screen") {
                        beforeEach {
                            self.subject.viewWillAppear(false)
                        }

                        describe("when the issues repository returns some issues") {
                            beforeEach {
                                let issueA = Issue(title: "Big Money in Little DC", body: "body", imageURL: NSURL(string: "http://a.com")!, url: NSURL(string: "http://b.com")!)
                                let issueB = Issue(title: "Long Live The NHS", body: "body", imageURL: NSURL(string: "http://c.com")!, url: NSURL(string: "http://d.com")!)

                                self.issueRepository.lastCompletionBlock!([issueA, issueB])
                            }


                            it("shows the issues in the table") {
                                expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                                let cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IssueTableViewCell
                                expect(cellA.titleLabel.text).to(equal("Big Money in Little DC"))

                                let cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! IssueTableViewCell
                                expect(cellB.titleLabel.text).to(equal("Long Live The NHS"))
                            }
                        }
                    }
                }

                describe("Tapping on an issue") {
                    let expectedIssue = TestUtils.issue()

                    beforeEach {
                        self.subject.view.layoutIfNeeded()
                        self.subject.viewWillAppear(false)
                        let otherIssue = TestUtils.issue()

                        let issues = [otherIssue, expectedIssue]

                        self.issueRepository.lastCompletionBlock!(issues)

                        let tableView = self.subject.tableView
                        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                        tableView.delegate?.tableView!(tableView, didSelectRowAtIndexPath: indexPath)

                    }

                    it("tracks the content view with the analytics service") {
                        expect(self.analyticsService.lastContentViewName).to(equal(expectedIssue.title))
                        expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Issue))
                        expect(self.analyticsService.lastContentViewID).to(equal(expectedIssue.url.absoluteString))
                    }


                    it("should push a correctly configured issue controller onto the nav stack") {
                        expect(self.issueControllerProvider.lastIssue).to(beIdenticalTo(expectedIssue))
                        expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.issueControllerProvider.controller))
                    }

                    describe("and the view is shown again") {
                        it("deselects the selected table row") {
                            self.subject.viewWillAppear(false)

                            expect(self.subject.tableView.indexPathForSelectedRow).to(beNil())
                        }
                    }
                }
            }
        }
    }
}
