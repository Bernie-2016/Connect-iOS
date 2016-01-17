import Quick
import Nimble

@testable import Movement

class ActionsControllerSpec: QuickSpec {
    override func spec() {
        describe("ActionsController") {
            var subject: ActionsController!
            var urlProvider: URLProvider!
            var urlOpener: FakeURLOpener!
            var analyticsService: FakeAnalyticsService!
            var tabBarItemStylist: FakeTabBarItemStylist!
            var theme: Theme!

            beforeEach {
                urlProvider = ActionsControllerFakeURLProvider()
                urlOpener = FakeURLOpener()
                analyticsService = FakeAnalyticsService()
                tabBarItemStylist = FakeTabBarItemStylist()

                theme = ActionsControllerFakeTheme()

                subject = ActionsController(
                    urlProvider: urlProvider,
                    urlOpener: urlOpener,
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    theme: theme)
            }

            context("when the view loads") {
                beforeEach {
                    expect(subject.view).toNot(beNil())
                }

                it("has the correct title") {
                    expect(subject.title).to(equal("Actions"))
                }

                it("uses the tab bar item stylist to style its tab bar item") {
                    expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                    expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "actionsTabBarIconInactive")))
                    expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "actionsTabBarIcon")))
                }

                it("has a table view styled with the theme") {
                    expect(subject.view.subviews.count).to(equal(1))

                    let tableView = subject.view.subviews.first!
                    expect(tableView).to(beAnInstanceOf(UITableView.self))
                    expect(tableView.backgroundColor).to(equal(UIColor.orangeColor()))
                }

                describe("the table view contents") {
                    var tableView: UITableView!
                    beforeEach {
                        tableView = subject.view.subviews.first! as! UITableView
                    }

                    it("has two sections") {
                        expect(tableView.numberOfSections).to(equal(2))
                    }

                    it("styles the section headers with the theme") {
                        let sectionHeader = tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 0) as! ActionsSectionHeaderView

                        expect(sectionHeader.contentView.backgroundColor).to(equal(UIColor.darkGrayColor()))
                        expect(sectionHeader.textLabel!.textColor).to(equal(UIColor.lightGrayColor()))
                        expect(sectionHeader.textLabel!.font).to(equal(UIFont.italicSystemFontOfSize(999)))
                    }

                    describe("the fundraising section") {
                        it("has a section for fundraising") {
                            let header = tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 0) as! ActionsSectionHeaderView
                            expect(header.textLabel!.text).to(equal("FUNDRAISE"))
                        }

                        it("has the correct number of rows") {
                            expect(tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 0)).to(equal(2))
                        }

                        describe("the donation row") {
                            var cell: ActionTableViewCell!

                            beforeEach {
                                cell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ActionTableViewCell
                            }

                            it("has a row for donating to the campaign") {
                                expect(cell.titleLabel.text).to(equal("Donate to the Campaign"))
                                expect(cell.subTitleLabel.text).to(equal("Contribute via the official campaign website"))
                                expect(cell.iconImageView.image).to(equal(UIImage(named: "Donate")))
                            }

                            it("applies the theme to the cell") {
                                expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(111)))
                                expect(cell.titleLabel.textColor).to(equal(UIColor.purpleColor()))
                                expect(cell.subTitleLabel.font).to(equal(UIFont.boldSystemFontOfSize(222)))
                                expect(cell.subTitleLabel.textColor).to(equal(UIColor.magentaColor()))
                                expect(cell.disclosureView.color).to(equal(UIColor.greenColor()))
                            }


                            describe("tapping on the donate row") {
                                it("opens the donate page in safari") {
                                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                                    expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "https://example.com/donate")!))
                                }

                                it("should log a content view with the analytics service") {
                                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                                    expect(analyticsService.lastContentViewName).to(equal("Donate Form"))
                                    expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Actions))
                                    expect(analyticsService.lastContentViewID).to(equal("Donate Form"))
                                }
                            }
                        }

                        describe("the sharing the donation page row") {
                            var cell: ActionTableViewCell!

                            beforeEach {
                                cell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! ActionTableViewCell
                            }

                            it("has a row for sharing the donation page") {
                                expect(cell.titleLabel.text).to(equal("Share the Donate page"))
                                expect(cell.subTitleLabel.text).to(equal("Ask friends and family to donate"))
                                expect(cell.iconImageView.image).to(equal(UIImage(named: "ShareDonate")))
                            }

                            it("applies the theme to the cell") {
                                expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(111)))
                                expect(cell.titleLabel.textColor).to(equal(UIColor.purpleColor()))
                                expect(cell.subTitleLabel.font).to(equal(UIFont.boldSystemFontOfSize(222)))
                                expect(cell.subTitleLabel.textColor).to(equal(UIColor.magentaColor()))
                                expect(cell.disclosureView.color).to(equal(UIColor.greenColor()))
                            }

                            describe("tapping on the sharing the donation page row") {
                                beforeEach {
                                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                                }

                                it("should present an activity view controller for sharing the story URL") {
                                    let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                    let activityItems = activityViewControler.activityItems()

                                    expect(activityItems.count).to(equal(1))
                                    expect(activityItems.first as? NSURL).to(equal(NSURL(string: "https://example.com/donate")!))
                                }

                                it("logs that the user tapped share") {
                                    expect(analyticsService.lastCustomEventName).to(equal("Began Share"))
                                    let expectedAttributes = [
                                        AnalyticsServiceConstants.contentIDKey: NSURL(string: "https://example.com/donate")!.absoluteString,
                                        AnalyticsServiceConstants.contentNameKey: "Donate Form",
                                        AnalyticsServiceConstants.contentTypeKey: "Actions"
                                    ]

                                    expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                                }

                                context("and the user completes the share succesfully") {
                                    it("tracks the share via the analytics service") {
                                        let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                        activityViewControler.completionWithItemsHandler!("Some activity", true, nil, nil)

                                        expect(analyticsService.lastShareActivityType).to(equal("Some activity"))
                                        expect(analyticsService.lastShareContentName).to(equal("Donate Form"))
                                        expect(analyticsService.lastShareContentType!).to(equal(AnalyticsServiceContentType.Actions))
                                        expect(analyticsService.lastShareID).to(equal(NSURL(string: "https://example.com/donate")!.absoluteString))
                                    }
                                }

                                context("and the user cancels the share") {
                                    it("tracks the share cancellation via the analytics service") {
                                        let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                        activityViewControler.completionWithItemsHandler!(nil, false, nil, nil)

                                        expect(analyticsService.lastCustomEventName).to(equal("Cancelled Share"))
                                        let expectedAttributes = [
                                            AnalyticsServiceConstants.contentIDKey: NSURL(string: "https://example.com/donate")!.absoluteString,
                                            AnalyticsServiceConstants.contentNameKey: "Donate Form",
                                            AnalyticsServiceConstants.contentTypeKey: "Actions"
                                        ]
                                        expect(analyticsService.lastCustomEventAttributes! as? [String: String]).to(equal(expectedAttributes))
                                    }
                                }

                                context("and there is an error when sharing") {
                                    it("tracks the error via the analytics service") {
                                        let expectedError = NSError(domain: "a", code: 0, userInfo: nil)
                                        let activityViewControler = subject.presentedViewController as! UIActivityViewController
                                        activityViewControler.completionWithItemsHandler!("asdf", true, nil, expectedError)

                                        expect(analyticsService.lastError as NSError).to(beIdenticalTo(expectedError))
                                        expect(analyticsService.lastErrorContext).to(equal("Failed to share Donate Form"))
                                    }
                                }
                            }
                        }
                    }

                    describe("the organizing section") {
                        it("has a section for organizing") {
                            let header = tableView.delegate?.tableView!(tableView, viewForHeaderInSection: 1) as! ActionsSectionHeaderView
                            expect(header.textLabel!.text).to(equal("ORGANIZE"))
                        }

                        it("has the correct number of rows") {
                            expect(tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 1)).to(equal(1))
                        }

                        describe("host an event row") {
                            var cell: ActionTableViewCell!
                            beforeEach {
                                cell = tableView.dataSource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ActionTableViewCell
                            }

                            it("has a row for hosting an event") {
                                expect(cell.titleLabel.text).to(equal("Host an event"))
                                expect(cell.subTitleLabel.text).to(equal("Organize supporters in your area"))
                                expect(cell.iconImageView.image).to(equal(UIImage(named: "HostEvent")))
                            }

                            it("applies the theme to the cell") {
                                expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(111)))
                                expect(cell.titleLabel.textColor).to(equal(UIColor.purpleColor()))
                                expect(cell.subTitleLabel.font).to(equal(UIFont.boldSystemFontOfSize(222)))
                                expect(cell.subTitleLabel.textColor).to(equal(UIColor.magentaColor()))
                                expect(cell.disclosureView.color).to(equal(UIColor.greenColor()))
                                expect(cell.backgroundColor).to(equal(UIColor.yellowColor()))
                            }

                            describe("tapping on the host an event row") {
                                it("opens the host event page in safari") {
                                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))

                                    expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "https://example.com/host")!))
                                }

                                it("should log a content view with the analytics service") {
                                    tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))

                                    expect(analyticsService.lastContentViewName).to(equal("Host Event Form"))
                                    expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Actions))
                                    expect(analyticsService.lastContentViewID).to(equal("Host Event Form"))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private class ActionsControllerFakeURLProvider: FakeURLProvider {
    override func donateFormURL() -> NSURL {
        return NSURL(string: "https://example.com/donate")!
    }

    private override func hostEventFormURL() -> NSURL {
        return NSURL(string: "https://example.com/host")!
    }
}

private class ActionsControllerFakeTheme: FakeTheme {
    override func defaultBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func defaultDisclosureColor() -> UIColor { return UIColor.greenColor() }
    override func actionsTitleFont() -> UIFont { return UIFont.boldSystemFontOfSize(111) }
    override func actionsTitleTextColor() -> UIColor { return UIColor.purpleColor() }
    override func actionsSubTitleFont() -> UIFont { return UIFont.boldSystemFontOfSize(222) }
    override func actionsSubTitleTextColor() -> UIColor { return UIColor.magentaColor() }
    override func defaultTableSectionHeaderBackgroundColor() -> UIColor { return UIColor.darkGrayColor() }
    override func defaultTableSectionHeaderTextColor() -> UIColor { return UIColor.lightGrayColor() }
    override func defaultTableSectionHeaderFont() -> UIFont { return UIFont.italicSystemFontOfSize(999) }
    override func defaultTableCellBackgroundColor() -> UIColor { return UIColor.yellowColor() }
}
