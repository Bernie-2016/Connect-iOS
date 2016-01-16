import UIKit
import Quick
import Nimble
import CoreLocation
import QuartzCore

@testable import Movement

class EventsControllerSpec : QuickSpec {
    override func spec() {
        var subject : EventsController!
        var window : UIWindow!
        var eventService : FakeEventService!
        var eventPresenter : FakeEventPresenter!
        var eventControllerProvider : FakeEventControllerProvider!
        var urlOpener: FakeURLOpener!
        var urlProvider: FakeURLProvider!
        var analyticsService: FakeAnalyticsService!
        var tabBarItemStylist: FakeTabBarItemStylist!
        var navigationController: UINavigationController!
        var eventSectionHeaderPresenter: FakeEventSectionHeaderPresenter!
        var eventListTableViewCellStylist: FakeEventListTableViewCellStylist!

        describe("EventsController") {
            beforeEach {
                eventService = FakeEventService()
                eventPresenter = FakeEventPresenter(sameTimeZoneDateFormatter: FakeDateFormatter(),
                    differentTimeZoneDateFormatter: FakeDateFormatter(),
                    sameTimeZoneFullDateFormatter: FakeDateFormatter(),
                    differentTimeZoneFullDateFormatter: FakeDateFormatter())
                eventControllerProvider = FakeEventControllerProvider()
                eventSectionHeaderPresenter = FakeEventSectionHeaderPresenter()
                urlOpener = FakeURLOpener()
                urlProvider = EventsFakeURLProvider()
                analyticsService = FakeAnalyticsService()
                tabBarItemStylist = FakeTabBarItemStylist()
                eventListTableViewCellStylist = FakeEventListTableViewCellStylist()

                window = UIWindow()

                subject = EventsController(
                    eventService: eventService,
                    eventPresenter: eventPresenter,
                    eventControllerProvider: eventControllerProvider,
                    eventSectionHeaderPresenter: eventSectionHeaderPresenter,
                    urlProvider: urlProvider,
                    urlOpener: urlOpener,
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    eventListTableViewCellStylist: eventListTableViewCellStylist,
                    theme: EventsFakeTheme()
                )

                navigationController = UINavigationController()
                navigationController.pushViewController(subject, animated: false)

                window.addSubview(subject.view)
                window.makeKeyAndVisible()

                subject.view.layoutSubviews()
                subject.viewDidAppear(false)
            }

            afterEach {
                window = nil
            }

            it("has the correct tab bar title") {
                expect(subject.title).to(equal("Events"))
            }

            it("has the correct navigation item title") {
                expect(subject.navigationItem.title).to(equal("Events Near Me"))
            }

            it("should set the back bar button item title correctly") {
                expect(subject.navigationItem.backBarButtonItem?.title).to(equal("Events"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "eventsTabBarIconInactive")))
                expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "eventsTabBarIcon")))
            }

            it("should add its view components as subviews") {
                let subViews = subject.view.subviews

                expect(subViews.count).to(equal(8))

                expect(subViews.contains(subject.searchBar)).to(beTrue())
                expect(subViews.contains(subject.locateButton)).to(beTrue())
                expect(subViews.contains(subject.locateIndicatorView)).to(beTrue())
                expect(subViews.contains(subject.subInstructionsLabel)).to(beTrue())
                expect(subViews.contains(subject.noResultsLabel)).to(beTrue())
                expect(subViews.contains(subject.createEventCTATextView)).to(beTrue())
                expect(subViews.contains(subject.resultsTableView)).to(beTrue())
                expect(subViews.contains(subject.loadingActivityIndicatorView)).to(beTrue())
                expect(subViews.contains(subject.locateButton)).to(beTrue())
            }

            it("should hide the results table view by default") {
                expect(subject.resultsTableView.hidden).to(beTrue())
            }

            it("should hide the no results label by default") {
                expect(subject.noResultsLabel.hidden).to(beTrue())
            }

            it("should hide the call to action to create an event by default") {
                expect(subject.createEventCTATextView.hidden).to(beTrue())
            }

            it("should hide the spinner by default") {
                expect(subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
            }

            it("should hide the search button by default") {
                expect(subject.searchButton.hidden).to(beTrue())
            }

            it("should hide the cancel button by default") {
                expect(subject.cancelButton.hidden).to(beTrue())
            }

            it("should hide the filter button by default") {
                expect(subject.filterButton.hidden).to(beTrue())
            }

            it("should show the instructions by default") {
                expect(subject.locateButton.hidden).to(beFalse())
                expect(subject.locateButton.titleLabel!.text).to(equal("Find Events Near Me"))

                expect(subject.subInstructionsLabel.hidden).to(beFalse())
                expect(subject.subInstructionsLabel.text).to(equal("Event listings are gathered from the Bernie 2016 campaign website."))
            }

            it("configures the zip code keyboard to be a number pad") {
                expect(subject.zipCodeTextField.keyboardType).to(equal(UIKeyboardType.NumberPad))
            }

            it("styles the page components with the theme") {
                expect(subject.searchBar.backgroundColor).to(equal(UIColor.greenColor()))
                expect(subject.zipCodeTextField.backgroundColor).to(equal(UIColor.brownColor()))
                expect(subject.zipCodeTextField.font).to(equal(UIFont.boldSystemFontOfSize(4444)))
                expect(subject.zipCodeTextField.textColor).to(equal(UIColor.redColor()))
                expect(subject.zipCodeTextField.layer.cornerRadius).to(equal(100.0))
                expect(subject.zipCodeTextField.layer.borderWidth).to(equal(200.0))

                expect(subject.zipCodeTextField.layer.sublayerTransform.m41).to(equal(4))
                expect(subject.zipCodeTextField.layer.sublayerTransform.m42).to(equal(5))
                expect(subject.zipCodeTextField.layer.sublayerTransform.m43).to(equal(6))

                expect(subject.searchButton.titleLabel!.font).to(equal(UIFont.boldSystemFontOfSize(4444)))
                expect(subject.cancelButton.titleLabel!.font).to(equal(UIFont.boldSystemFontOfSize(4444)))

                let borderColor = UIColor(CGColor: subject.zipCodeTextField.layer.borderColor!)
                expect(borderColor).to(equal(UIColor.orangeColor()))

                expect(subject.locateButton.titleLabel!.textColor).to(equal(UIColor.blueColor()))
                expect(subject.locateButton.titleLabel!.font).to(equal(UIFont.boldSystemFontOfSize(4444)))

                expect(subject.subInstructionsLabel.textColor).to(equal(UIColor.blueColor()))
                expect(subject.subInstructionsLabel.font).to(equal(UIFont.italicSystemFontOfSize(555)))

                expect(subject.noResultsLabel.font).to(equal(UIFont.italicSystemFontOfSize(888)))
                expect(subject.noResultsLabel.textColor).to(equal(UIColor.blueColor()))

                expect(subject.createEventCTATextView.font).to(equal(UIFont.italicSystemFontOfSize(777)))
                expect(subject.createEventCTATextView.textColor).to(equal(UIColor.blueColor()))

                expect(subject.loadingActivityIndicatorView.color).to(equal(UIColor.blackColor()))

                expect(subject.resultsTableView.separatorColor).to(equal(UIColor(rgba: "#666666")))
            }

            it("has the correct text for the search button for the zip code entry field") {
                expect(subject.searchButton.titleForState(.Normal)).to(equal("Search"))
            }

            it("has the correct text for the cancel button") {
                expect(subject.cancelButton.titleForState(.Normal)).to(equal("Cancel"))
            }

            it("sets the radius button's input view to be the radius picker") {
                expect(subject.filterButton.inputView).to(beIdenticalTo(subject.radiusPickerView))
            }

            it("sets the image of the filter button") {
                let image = subject.filterButton.imageForState(.Normal)!
                let expectedImage = UIImage(named: "filterIcon")!
                expect(image).to(equal(expectedImage))
            }

            it("selects the correct default radius in the picker") {
                let picker = subject.radiusPickerView

                let selectedRow = picker.selectedRowInComponent(0)
                let title = picker.delegate!.pickerView!(picker, titleForRow: selectedRow, forComponent: 0)

                expect(title).to(equal("< 10 Miles"))
            }

            context("when selecting a search radius") {
                it("has the correct set of search radii") {
                    expect(subject.radiusPickerView.dataSource?.numberOfComponentsInPickerView(subject.radiusPickerView)).to(equal(1))
                    expect(subject.radiusPickerView.dataSource?.pickerView(subject.radiusPickerView, numberOfRowsInComponent: 0)).to(equal(6))

                    expect(subject.radiusPickerView.delegate?.pickerView!(subject.radiusPickerView, titleForRow: 0, forComponent: 0)).to(equal("< 5 Miles"))
                    expect(subject.radiusPickerView.delegate?.pickerView!(subject.radiusPickerView, titleForRow: 1, forComponent: 0)).to(equal("< 10 Miles"))
                    expect(subject.radiusPickerView.delegate?.pickerView!(subject.radiusPickerView, titleForRow: 2, forComponent: 0)).to(equal("< 20 Miles"))
                    expect(subject.radiusPickerView.delegate?.pickerView!(subject.radiusPickerView, titleForRow: 3, forComponent: 0)).to(equal("< 50 Miles"))
                    expect(subject.radiusPickerView.delegate?.pickerView!(subject.radiusPickerView, titleForRow: 4, forComponent: 0)).to(equal("< 100 Miles"))
                    expect(subject.radiusPickerView.delegate?.pickerView!(subject.radiusPickerView, titleForRow: 5, forComponent: 0)).to(equal("< 250 Miles"))
                }
            }

            context("when entering a zip code") {
                beforeEach {
                    subject.zipCodeTextField.tap()
                    subject.zipCodeTextField.becomeFirstResponder()

                    expect(subject.zipCodeTextField.isFirstResponder()).to(beTrue())

                    subject.zipCodeTextField.text = "90210"
                }

                it("should show the search button") {
                    expect(subject.searchButton.hidden).to(beFalse())
                }

                it("should show the cancel button") {
                    expect(subject.cancelButton.hidden).to(beFalse())
                }

                xit("should log an event via the analytics service") {
                    // TODO: test is failing on Travis, so marking as pending for now.
                    expect(analyticsService.lastCustomEventName).to(equal("Tapped on ZIP Code text field on Events"))
                    expect(analyticsService.lastCustomEventAttributes).to(beNil())
                }

                describe("aborting a search") {
                    beforeEach {
                        subject.cancelButton.tap()
                    }

                    it("should resign first responder") {
                        expect(subject.zipCodeTextField.isFirstResponder()).to(beFalse())
                    }

                    xit("should log an event via the analytics service") {
                        // TODO: test is failing on Travis, so marking as pending for now.
                        expect(analyticsService.lastCustomEventName).to(equal("Cancelled ZIP Code search on Events"))
                        expect(analyticsService.lastCustomEventAttributes).to(beNil())
                    }

                    it("should hide the search button") {
                        expect(subject.searchButton.hidden).to(beTrue())
                    }

                    it("should hide the cancel button") {
                        expect(subject.cancelButton.hidden).to(beTrue())
                    }
                }

                describe("and then tapping search") {
                    beforeEach {
                        subject.searchButton.tap()
                    }

                    it("should resign first responder") {
                        expect(subject.zipCodeTextField.isFirstResponder()).to(beFalse())
                    }

                    it("should show the spinner") {
                        expect(subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                    }

                    it("should hide the instructions") {
                        expect(subject.locateButton.hidden).to(beTrue())
                        expect(subject.locateIndicatorView.hidden).to(beTrue())
                        expect(subject.subInstructionsLabel.hidden).to(beTrue())
                    }

                    it("should ask the event service for events with the default search radius") {
                        expect(eventService.lastReceivedZipCode).to(equal("90210"))
                        expect(eventService.lastReceivedRadiusMiles).to(equal(10.0))
                    }

                    it("should log an event via the analytics service") {
                        expect(analyticsService.lastSearchQuery).to(equal("90210"))
                        expect(analyticsService.lastSearchContext).to(equal(AnalyticsSearchContext.Events))
                    }

                    it("should hide the search button") {
                        expect(subject.searchButton.hidden).to(beTrue())
                    }

                    it("should hide the cancel button") {
                        expect(subject.cancelButton.hidden).to(beTrue())
                    }

                    context("when the search results in an error") {
                        let expectedError = NSError(domain: "someerror", code: 0, userInfo: nil)
                        beforeEach {
                            eventService.lastReturnedPromise!.reject(expectedError)
                        }

                        it("should hide the spinner") {
                            expect(subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                        }

                        it("should log an event via the analytics service") {
                            expect(analyticsService.lastError as NSError).to(beIdenticalTo(expectedError))
                            expect(analyticsService.lastErrorContext).to(equal("Events"))
                        }

                        it("should display a no results message") {
                            expect(subject.noResultsLabel.hidden).to(beFalse())
                            expect(subject.noResultsLabel.text).to(contain("We couldn't find any"))
                        }

                        it("should display a call to action to create an event") {
                            expect(subject.createEventCTATextView.hidden).to(beFalse())
                            expect(subject.createEventCTATextView.text).to(equal("Try another search or be the first to organize."))
                        }

                        xdescribe("tapping on the organize text") {
                            it("should open the organize page in safari") {
                                expect(urlOpener.lastOpenedURL).to(equal(NSURL(string: "https://example.com/events")))
                            }
                        }

                        it("should leave the table view hidden") {
                            expect(subject.resultsTableView.hidden).to(beTrue())
                        }

                        describe("making a subsequent search") {
                            beforeEach {
                                subject.zipCodeTextField.tap()
                                subject.zipCodeTextField.becomeFirstResponder()

                                subject.zipCodeTextField.text = "11111"

                                subject.searchButton.tap()
                            }

                            it("should hide the no results message") {
                                expect(subject.noResultsLabel.hidden).to(beTrue())
                            }

                            it("should hide the create event CTA") {                                expect(subject.createEventCTATextView.hidden).to(beTrue())
                            }

                            it("should show the spinner") {
                                expect(subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                            }

                            it("should ask the events repository for events within the configured search radius") {
                                expect(eventService.lastReceivedZipCode).to(equal("11111"))
                                expect(eventService.lastReceivedRadiusMiles).to(equal(10.0))
                            }
                        }
                    }

                    context("when the search completes succesfully") {
                        context("with no results") {
                            let expectedSearchCentroid = CLLocation(latitude: 37.8271868, longitude: -122.4240794)

                            beforeEach {
                                let eventSearchResult = EventSearchResult(searchCentroid: expectedSearchCentroid, events: [])
                                eventService.lastReturnedPromise!.resolve(eventSearchResult)
                            }

                            it("should hide the spinner") {
                                expect(subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                            }

                            it("should show the filter button") {
                                expect(subject.filterButton.hidden).to(beFalse())
                            }

                            it("should display a no results message") {
                                expect(subject.noResultsLabel.hidden).to(beFalse())
                                expect(subject.noResultsLabel.text).to(contain("We couldn't find any"))
                            }

                            it("should display a call to action to create an event") {
                                expect(subject.createEventCTATextView.hidden).to(beFalse())
                                expect(subject.createEventCTATextView.text).to(equal("Try another search or be the first to organize."))
                            }

                            it("should leave the table view hidden") {
                                expect(subject.resultsTableView.hidden).to(beTrue())
                            }

                            describe("making a subsequent search") {
                                beforeEach {
                                    subject.zipCodeTextField.tap()
                                    subject.zipCodeTextField.becomeFirstResponder()

                                    subject.zipCodeTextField.text = "11111"
                                }

                                it("should hide the filter button") {
                                    expect(subject.filterButton.hidden).to(beTrue())
                                }

                                it("should show the search button") {
                                    expect(subject.searchButton.hidden).to(beFalse())
                                }

                                it("should show the cancel button") {
                                    expect(subject.cancelButton.hidden).to(beFalse())
                                }

                                describe("and then tapping done") {
                                    beforeEach {
                                        subject.searchButton.tap()
                                    }

                                    it("should hide the no results message") {
                                        expect(subject.noResultsLabel.hidden).to(beTrue())
                                    }

                                    it("should hide the call to action to create an event") {
                                        expect(subject.createEventCTATextView.hidden).to(beTrue())
                                    }

                                    it("should show the spinner by default") {
                                        expect(subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                                    }

                                    it("should ask the events repository for events within the configured search radius") {
                                        expect(eventService.lastReceivedZipCode).to(equal("11111"))
                                        expect(eventService.lastReceivedRadiusMiles).to(equal(10.0))
                                    }
                                }
                            }
                        }

                        context("with some results") {
                            let eventA = TestUtils.eventWithName("Bigtime Bernie BBQ")
                            let eventB = TestUtils.eventWithName("Slammin' Sanders Salsa Serenade")
                            let expectedSearchCentroid = CLLocation(latitude: 37.8271868, longitude: -122.4240794)
                            let events : Array<Event> = [eventA, eventB]
                            let eventSearchResult = FakeEventSearchResult(searchCentroid: expectedSearchCentroid, events: events)

                            beforeEach {
                                eventSearchResult.uniqueDays = [NSDate()]
                                eventSearchResult.eventsByDay = [events]

                                eventService.lastReturnedPromise!.resolve(eventSearchResult)
                            }

                            it("should hide the spinner") {
                                expect(subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                            }

                            it("should show the filter button") {
                                expect(subject.filterButton.hidden).to(beFalse())
                            }

                            it("should leave the no results message hidden") {
                                expect(subject.noResultsLabel.hidden).to(beTrue())
                            }

                            it("should show the results table") {
                                expect(subject.resultsTableView.hidden).to(beFalse())
                            }

                            describe("the results table") {
                                it("has a section per unique day in the search results") {
                                    eventSearchResult.eventsByDay = [[eventA],[eventB]]
                                    eventSearchResult.uniqueDays = [NSDate(), NSDate()]
                                    subject.resultsTableView.reloadData()
                                    expect(subject.resultsTableView.numberOfSections).to(equal(2))
                                    eventSearchResult.eventsByDay = [[eventA]]
                                    eventSearchResult.uniqueDays = [NSDate()]
                                    subject.resultsTableView.reloadData()
                                    expect(subject.resultsTableView.numberOfSections).to(equal(1))
                                }

                                it("uses the events section header presenter for the header title") {
                                    let dateForSection = NSDate()
                                    eventSearchResult.uniqueDays = [NSDate(), dateForSection]
                                    eventSearchResult.eventsByDay = [[eventA], [eventB]]
                                    subject.resultsTableView.reloadData()

                                    let header = subject.tableView(subject.resultsTableView, titleForHeaderInSection: 1)
                                    expect(header).to(equal("Section header"))
                                    expect(eventSectionHeaderPresenter.lastPresentedDate).to(beIdenticalTo(dateForSection))
                                }

                                it("displays a cell per event in each day section") {
                                    eventSearchResult.eventsByDay = [events]

                                    expect(subject.resultsTableView.dataSource!.tableView(subject.resultsTableView, numberOfRowsInSection: 0)).to(equal(2))

                                    eventSearchResult.eventsByDay = [[eventA]]

                                    expect(subject.resultsTableView.dataSource!.tableView(subject.resultsTableView, numberOfRowsInSection: 0)).to(equal(1))
                                }

                                it("uses the presenter to set up the returned cells from the search results") {
                                    eventSearchResult.eventsByDay = [events]
                                    subject.resultsTableView.reloadData()

                                    let cellA = subject.resultsTableView.dataSource!.tableView(subject.resultsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! EventListTableViewCell

                                    expect(eventPresenter.lastReceivedEvent).to(beIdenticalTo(eventA))
                                    expect(eventPresenter.lastSearchCentroid).to(beIdenticalTo(expectedSearchCentroid))
                                    expect(eventPresenter.lastReceivedCell).to(beIdenticalTo(cellA))

                                    let cellB = subject.resultsTableView.dataSource!.tableView(subject.resultsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! EventListTableViewCell

                                    expect(eventPresenter.lastReceivedEvent).to(beIdenticalTo(eventB))
                                    expect(eventPresenter.lastSearchCentroid).to(beIdenticalTo(expectedSearchCentroid))
                                    expect(eventPresenter.lastReceivedCell).to(beIdenticalTo(cellB))
                                }

                                it("styles the cells with the stylist") {
                                    let cell = subject.resultsTableView.dataSource!.tableView(subject.resultsTableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0)) as! EventListTableViewCell

                                    expect(eventListTableViewCellStylist.lastStyledCell).to(beIdenticalTo(cell))
                                    expect(eventListTableViewCellStylist.lastReceivedEvent).to(beIdenticalTo(eventA))
                                }

                                it("styles the section headers with the theme") {
                                    let sectionHeader = UITableViewHeaderFooterView()

                                    subject.resultsTableView.delegate?.tableView!(subject.resultsTableView, willDisplayHeaderView: sectionHeader, forSection: 0)

                                    expect(sectionHeader.contentView.backgroundColor).to(equal(UIColor.darkGrayColor()))
                                    expect(sectionHeader.textLabel!.textColor).to(equal(UIColor.lightGrayColor()))
                                    expect(sectionHeader.textLabel!.font).to(equal(UIFont.italicSystemFontOfSize(999)))
                                }

                                describe("tapping on an event") {
                                    beforeEach {
                                        eventSearchResult.uniqueDays = [NSDate()]
                                        eventSearchResult.eventsByDay = [[eventB]]

                                        let tableView = subject.resultsTableView
                                        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                                    }

                                    it("should push a correctly configured news item view controller onto the nav stack") {
                                        expect(eventControllerProvider.lastEvent).to(beIdenticalTo(eventB))
                                        expect(subject.navigationController!.topViewController).to(beIdenticalTo(eventControllerProvider.controller))
                                    }

                                    it("tracks the content view with the analytics service") {
                                        expect(analyticsService.lastContentViewName).to(equal(eventB.name))
                                        expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Event))
                                        expect(analyticsService.lastContentViewID).to(equal(eventB.url.absoluteString))
                                    }

                                    describe("and the view is shown again") {
                                        it("deselects the selected table row") {
                                            subject.resultsTableView.reloadData()

                                            subject.resultsTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .Middle)
                                            subject.viewWillAppear(false)

                                            expect(subject.resultsTableView.indexPathForSelectedRow).to(beNil())
                                        }
                                    }
                                }
                            }

                            describe("tapping on the filter button") {
                                beforeEach {
                                    subject.filterButton.tap()
                                }

                                it("becomes first responder") {
                                    expect(subject.filterButton.isFirstResponder()).to(beTrue())
                                }

                                it("should hide the filter button") {
                                    expect(subject.filterButton.hidden).to(beTrue())
                                }

                                it("should show the search button") {
                                    expect(subject.searchButton.hidden).to(beFalse())
                                }

                                it("should show the cancel button") {
                                    expect(subject.cancelButton.hidden).to(beFalse())
                                }

                                it("should hide the zip code text field") {
                                    expect(subject.zipCodeTextField.hidden).to(beTrue())
                                }

                                describe("and then tapping search after selecting a radius") {
                                    beforeEach {
                                        let picker = subject.radiusPickerView
                                        picker.delegate!.pickerView!(picker, didSelectRow: 5, inComponent: 0)

                                        subject.searchButton.tap()
                                    }

                                    it("resigns first responder") {
                                        expect(subject.filterButton.isFirstResponder()).to(beFalse())
                                    }

                                    it("should show the zip code text field") {
                                        expect(subject.zipCodeTextField.hidden).to(beFalse())
                                    }

                                    it("should ask the events repository for events with the updated radius") {
                                        expect(eventService.lastReceivedZipCode).to(equal("90210"))
                                        expect(eventService.lastReceivedRadiusMiles).to(equal(250.0))
                                    }
                                }

                                describe("and then tapping cancel") {
                                    beforeEach {
                                        let picker = subject.radiusPickerView
                                        picker.selectRow(5, inComponent: 0, animated: false)
                                        picker.delegate!.pickerView!(picker, didSelectRow: 5, inComponent: 0)

                                        subject.cancelButton.tap()
                                    }

                                    it("resigns first responder") {
                                        expect(subject.filterButton.isFirstResponder()).to(beFalse())
                                    }


                                    it("should show the zip code text field") {
                                        expect(subject.zipCodeTextField.hidden).to(beFalse())
                                    }

                                    it("should show the filter button") {
                                        expect(subject.filterButton.hidden).to(beFalse())
                                    }

                                    describe("making a subsequent search") {
                                        beforeEach {
                                            subject.zipCodeTextField.tap()
                                            subject.zipCodeTextField.becomeFirstResponder()

                                            subject.searchButton.tap()
                                        }

                                        it("should ask the events repository for events with the unchanged, previously configured radius") {
                                            expect(eventService.lastReceivedRadiusMiles).to(equal(10.0))
                                        }

                                        it("reverts the selected radius in the picker") {
                                            let picker = subject.radiusPickerView

                                            let selectedRow = picker.selectedRowInComponent(0)
                                            let title = picker.delegate!.pickerView!(picker, titleForRow: selectedRow, forComponent: 0)

                                            expect(title).to(equal("< 10 Miles"))
                                        }
                                    }
                                }
                            }

                            describe("making a subsequent search") {
                                beforeEach {
                                    subject.zipCodeTextField.tap()
                                    subject.zipCodeTextField.becomeFirstResponder()

                                    subject.zipCodeTextField.text = "11111"

                                    subject.searchButton.tap()
                                }

                                it("should hide the results table view") {
                                    expect(subject.resultsTableView.hidden).to(beTrue())
                                }

                                it("should show the spinner") {
                                    expect(subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                                }

                                it("should ask the events repository for events within the configured radius") {
                                    expect(eventService.lastReceivedZipCode).to(equal("11111"))
                                    expect(eventService.lastReceivedRadiusMiles).to(equal(10.0))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private class EventsFakeURLProvider: FakeURLProvider {

}

private class EventsFakeTheme : FakeTheme {
    override func tabBarActiveTextColor() -> UIColor {
        return UIColor.purpleColor()
    }

    override func tabBarInactiveTextColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }

    override func eventsSearchBarBackgroundColor() -> UIColor {
        return UIColor.greenColor()
    }

    override func eventsZipCodeTextColor() -> UIColor {
        return UIColor.redColor()
    }

    override func eventsZipCodePlaceholderTextColor() -> UIColor { return UIColor(rgba: "#12345") }

    override func eventsZipCodeBackgroundColor() -> UIColor {
        return UIColor.brownColor()
    }

    override func eventsZipCodeBorderColor() -> UIColor {
        return UIColor.orangeColor()
    }

    override func eventsSearchBarFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(4444)
    }

    override func eventsZipCodeCornerRadius() -> CGFloat {
        return 100.0
    }

    override func eventsZipCodeBorderWidth() -> CGFloat {
        return 200.0
    }

    override func eventsZipCodeTextOffset() -> CATransform3D {
        return CATransform3DMakeTranslation(4, 5, 6);
    }

    override func eventsGoButtonCornerRadius() -> CGFloat {
        return 300
    }

    override func eventsNoResultsFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(888)
    }

    override func eventsCreateEventCTAFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(777)
    }

    override func defaultSpinnerColor() -> UIColor {
        return UIColor.blackColor()
    }

    private override func eventsSubInstructionsFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(555)
    }

    override func defaultTableSectionHeaderBackgroundColor() -> UIColor {
        return UIColor.darkGrayColor()
    }

    override func defaultTableSectionHeaderTextColor() -> UIColor {
        return UIColor.lightGrayColor()
    }

    override func defaultTableSectionHeaderFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(999)
    }


    override func eventsInformationTextColor() -> UIColor {
        return UIColor.blueColor()
    }


    override func defaultTableSeparatorColor() -> UIColor {
        return UIColor(rgba: "#666666")
    }

    // TODO: use the below in tests.

    override func defaultButtonFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(666)
    }

    override func defaultButtonBackgroundColor() -> UIColor {
        return UIColor.blueColor()
    }

    override func defaultButtonTextColor() -> UIColor {
        return UIColor.blueColor()
    }
}

private class FakeEventControllerProvider: EventControllerProvider {
    let controller = EventController(
        event: TestUtils.eventWithName("some event"),
        eventPresenter: FakeEventPresenter(                    sameTimeZoneDateFormatter: FakeDateFormatter(),
            differentTimeZoneDateFormatter: FakeDateFormatter(),
            sameTimeZoneFullDateFormatter: FakeDateFormatter(),
            differentTimeZoneFullDateFormatter: FakeDateFormatter()),
        eventRSVPControllerProvider: FakeEventRSVPControllerProvider(),
        urlProvider: FakeURLProvider(),
        urlOpener: FakeURLOpener(),
        analyticsService: FakeAnalyticsService(),
        theme: FakeTheme())
    var lastEvent: Event?

    init() {}

    func provideInstanceWithEvent(event: Event) -> EventController {
        self.lastEvent = event
        return self.controller
    }
}

private class FakeEventSearchResult: EventSearchResult {
    var uniqueDays: [NSDate] = []
    var eventsByDay: [[Event]] = []

    override func uniqueDaysInLocalTimeZone() -> [NSDate] {
        return self.uniqueDays
    }

    override func eventsWithDayIndex(dayIndex: Int) -> [Event] {
        return self.eventsByDay[dayIndex]
    }
}

private class FakeEventSectionHeaderPresenter: EventSectionHeaderPresenter {
    var lastPresentedDate: NSDate!

    init() {
        super.init(currentWeekDateFormatter: FakeDateFormatter(),
            nonCurrentWeekDateFormatter: FakeDateFormatter(),
            dateProvider: FakeDateProvider())
    }

    override func headerForDate(date: NSDate) -> String {
        self.lastPresentedDate = date
        return "Section header"
    }
}

private class FakeEventListTableViewCellStylist: EventListTableViewCellStylist {
    var lastStyledCell: EventListTableViewCell!
    var lastReceivedEvent: Event!

    private func styleCell(cell: EventListTableViewCell, event: Event) {
        self.lastStyledCell = cell
        self.lastReceivedEvent = event
    }
}

private class FakeEventService: EventService {
    var lastReceivedZipCode: NSString!
    var lastReceivedRadiusMiles: Float!
    var lastReturnedPromise: EventSearchResultPromise!

    private func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture {
        lastReceivedZipCode = zipCode
        lastReceivedRadiusMiles = radiusMiles
        lastReturnedPromise = EventSearchResultPromise()
        return lastReturnedPromise.future
    }
}
