import UIKit
import Quick
import Nimble
import berniesanders
import QuartzCore

class ConnectFakeTheme : FakeTheme {
    override func tabBarActiveTextColor() -> UIColor {
        return UIColor.purpleColor()
    }
    
    override func tabBarInactiveTextColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
    
    override func connectListFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(333)
    }
    
    override func connectListColor() -> UIColor {
        return UIColor.yellowColor()
    }
    
    override func connectGoButtonFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(555)
    }
    
    override func connectGoButtonTextColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    override func connectGoButtonBackgroundColor() -> UIColor {
        return UIColor.greenColor()
    }
    
    override func connectZipCodeTextColor() -> UIColor {
        return UIColor.redColor()
    }
    
    override func connectZipCodeBackgroundColor() -> UIColor {
        return UIColor.brownColor()
    }
    
    override func connectZipCodeBorderColor() -> UIColor {
        return UIColor.orangeColor()
    }
    
    override func connectZipCodeFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(4444)
    }
    
    override func connectZipCodeCornerRadius() -> CGFloat {
        return 100.0
    }
    
    override func connectZipCodeBorderWidth() -> CGFloat {
        return 200.0
    }
    
    override func connectZipCodeTextOffset() -> CATransform3D {
        return CATransform3DMakeTranslation(4, 5, 6);
    }
    
    override func connectGoButtonCornerRadius() -> CGFloat {
        return 300
    }
    
    override func connectNoResultsFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(888)
    }
    
    override func connectNoResultsTextColor() -> UIColor {
        return UIColor.blueColor()
    }
    
    override func defaultSpinnerColor() -> UIColor {
        return UIColor.blackColor()
    }
}

class FakeEventRepository : EventRepository {
    var lastReceivedZipCode : NSString?
    var lastReceivedRadiusMiles : Float?
    var lastCompletionBlock: ((Array<Event>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    
    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float, completion: (Array<Event>) -> Void, error: (NSError) -> Void) {
        self.lastReceivedZipCode = zipCode
        self.lastReceivedRadiusMiles = radiusMiles
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class FakeEventListTableViewCellPresenter : EventListTableViewCellPresenter {
    var lastReceivedEvent: Event?
    var lastReceivedCell: EventListTableViewCell?
    
    override func presentEvent(event: Event, cell: EventListTableViewCell) -> EventListTableViewCell {
        lastReceivedEvent = event
        lastReceivedCell = cell
        return cell
    }
}

class ConnectControllerSpec : QuickSpec {
    var subject : ConnectController!
    var eventRepository : FakeEventRepository!
    var eventListTableViewCellPresenter : FakeEventListTableViewCellPresenter!
    let settingsController = TestUtils.settingsController()
    
    let navigationController = UINavigationController()
    
    override func spec() {
        describe("ConnectController") {
            beforeEach {
                self.eventRepository = FakeEventRepository()
                self.eventListTableViewCellPresenter = FakeEventListTableViewCellPresenter()
                
                self.subject = ConnectController(
                    eventRepository: self.eventRepository,
                    eventListTableViewCellPresenter: self.eventListTableViewCellPresenter,
                    settingsController: self.settingsController,
                    theme: ConnectFakeTheme()
                )
                
                self.navigationController.pushViewController(self.subject, animated: false)
                
                self.subject.view.layoutSubviews()
            }
            
            it("has the correct tab bar title") {
                expect(self.subject.title).to(equal("Connect"))
            }
            
            it("has the correct navigation item title") {
                expect(self.subject.navigationItem.title).to(equal("Connect"))
            }
            
            it("should set the back bar button item title correctly") {
                expect(self.subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }
            
            describe("tapping on the settings button") {
                it("should push the settings controller onto the nav stack") {
                    self.subject.navigationItem.leftBarButtonItem!.tap()
                    
                    expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.settingsController))
                }
            }
            
            it("styles its tab bar item from the theme") {
                let normalAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Normal)
                
                let normalTextColor = normalAttributes[NSForegroundColorAttributeName] as! UIColor
                let normalFont = normalAttributes[NSFontAttributeName] as! UIFont
                
                expect(normalTextColor).to(equal(UIColor.magentaColor()))
                expect(normalFont).to(equal(UIFont.systemFontOfSize(123)))
                
                let selectedAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Selected)
                
                let selectedTextColor = selectedAttributes[NSForegroundColorAttributeName] as! UIColor
                let selectedFont = selectedAttributes[NSFontAttributeName] as! UIFont
                
                expect(selectedTextColor).to(equal(UIColor.purpleColor()))
                expect(selectedFont).to(equal(UIFont.systemFontOfSize(123)))
            }
            
            it("should add its view components as subviews") {
                var subViews = self.subject.view.subviews as! [UIView]
                
                expect(contains(subViews, self.subject.zipCodeTextField)).to(beTrue())
                expect(contains(subViews, self.subject.eventSearchButton)).to(beTrue())
                expect(contains(subViews, self.subject.noResultsLabel)).to(beTrue())
                expect(contains(subViews, self.subject.resultsTableView)).to(beTrue())
                expect(contains(subViews, self.subject.loadingActivityIndicatorView)).to(beTrue())
            }
            
            it("should hide the results table view by default") {
                expect(self.subject.resultsTableView.hidden).to(beTrue())
            }
            
            it("should hide the no results label by default") {
                expect(self.subject.noResultsLabel.hidden).to(beTrue())
            }
            
            it("should hide the spinner by default") {
                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
            }
            
            it("has a search button button") {
                expect(self.subject.eventSearchButton.titleForState(.Normal)).to(equal("Go"))
            }
            
            it("styles the page components with the theme") {
                expect(self.subject.eventSearchButton.backgroundColor).to(equal(UIColor.greenColor()))
                expect(self.subject.eventSearchButton.titleLabel!.font).to(equal(UIFont.boldSystemFontOfSize(555)))
                expect(self.subject.eventSearchButton.layer.cornerRadius).to(equal(300.0))
                
                expect(self.subject.zipCodeTextField.backgroundColor).to(equal(UIColor.brownColor()))
                expect(self.subject.zipCodeTextField.font).to(equal(UIFont.boldSystemFontOfSize(4444)))
                expect(self.subject.zipCodeTextField.textColor).to(equal(UIColor.redColor()))
                expect(self.subject.zipCodeTextField.layer.cornerRadius).to(equal(100.0))
                expect(self.subject.zipCodeTextField.layer.borderWidth).to(equal(200.0))
                
                // TODO: Figure out how to test this.
                //                expect(self.subject.zipCodeTextField.layer.sublayerTransform).to(equal(CATransform3DMakeTranslation(4, 5, 6)))
                
                
                // TODO: why does this not compile?
                //                var a = self.subject.zipCodeTextField.layer.borderColor
                //                var b = UIColor.orangeColor().CGColor
                //                expect(a).to(equal(b))
                
                expect(self.subject.noResultsLabel.font).to(equal(UIFont.italicSystemFontOfSize(888)))
                expect(self.subject.noResultsLabel.textColor).to(equal(UIColor.blueColor()))
                
                expect(self.subject.loadingActivityIndicatorView.color).to(equal(UIColor.blackColor()))
            }
            
            describe("making a search by zip code") {
                xit("has the correct range of values in the radius picker") {
                    
                }
                
                xit("has the correct default value for the radius picker") {
                    
                }
                
                context("when entering an invalid zip code and range") {
                    xit("should display an error") {
                        
                    }
                    
                    xit("should not make a search") {
                        
                    }
                }
                
                context("when entering a valid zip code") {
                    beforeEach {
                        self.subject.zipCodeTextField.text = "90210"
                        self.subject.eventSearchButton.tap()
                    }
                    
                    it("should show the spinner") {
                        expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                    }

                    
                    it("should ask the events repository for events within 50 miles") {
                        expect(self.eventRepository.lastReceivedZipCode).to(equal("90210"))
                        expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                    }
                    
                    context("when the search results in an error") {
                        beforeEach {
                            self.eventRepository.lastErrorBlock!(NSError(domain: "someerror", code: 0, userInfo: nil))
                        }
                        
                        it("should hide the spinner") {
                            expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                        }

                        
                        it("should display a no results message") {
                            expect(self.subject.noResultsLabel.hidden).to(beFalse())
                            expect(self.subject.noResultsLabel.text).to(equal("No events match your search"))
                        }
                        
                        it("should leave the table view hidden") {
                            expect(self.subject.resultsTableView.hidden).to(beTrue())
                        }
                        
                        describe("making a subsequent search") {
                            beforeEach {
                                self.subject.zipCodeTextField.text = "11111"
                                
                                self.subject.eventSearchButton.tap()
                            }
                            
                            it("should hide the no results message") {
                                expect(self.subject.noResultsLabel.hidden).to(beTrue())
                            }
                            
                            it("should show the spinner") {
                                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                            }

                            it("should ask the events repository for events within 50 miles") {
                                expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                            }
                        }
                    }
                    
                    context("when the search completes succesfully") {
                        context("with no results") {
                            beforeEach {
                                var events : Array<Event> = []
                                self.eventRepository.lastCompletionBlock!(events)
                            }
                            
                            it("should hide the spinner") {
                                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                            }
                            
                            it("should display a no results message") {
                                expect(self.subject.noResultsLabel.hidden).to(beFalse())
                                expect(self.subject.noResultsLabel.text).to(equal("No events match your search"))
                            }
                            
                            it("should leave the table view hidden") {
                                expect(self.subject.resultsTableView.hidden).to(beTrue())
                            }
                            
                            describe("making a subsequent search") {
                                beforeEach {
                                    self.subject.zipCodeTextField.text = "11111"
                                    
                                    self.subject.eventSearchButton.tap()
                                }
                                
                                it("should hide the no results message") {
                                    expect(self.subject.noResultsLabel.hidden).to(beTrue())
                                }
                                
                                it("should show the spinner by default") {
                                    expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                                }
                                
                                it("should ask the events repository for events within 50 miles") {
                                    expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                    expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                                }
                            }
                        }
                        
                        context("with some results") {
                            let eventA = TestUtils.eventWithName("Bigtime Bernie BBQ")
                            let eventB = TestUtils.eventWithName("Slammin' Sanders Salsa Serenade")
                            
                            beforeEach {
                                var events : Array<Event> = [eventA, eventB]
                                self.eventRepository.lastCompletionBlock!(events)
                            }
                            
                            
                            it("should hide the spinner") {
                                expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beFalse())
                            }
                            
                            it("should leave the no results message hidden") {
                                expect(self.subject.noResultsLabel.hidden).to(beTrue())
                            }
                            
                            it("should show the results table") {
                                expect(self.subject.resultsTableView.hidden).to(beFalse())
                            }
                            
                            
                            describe("the results table") {
                                it("uses the presenter to set up the returned cells from the search results") {
                                    expect(self.subject.resultsTableView.numberOfSections()).to(equal(1))
                                    expect(self.subject.resultsTableView.numberOfRowsInSection(0)).to(equal(2))
                                    
                                    var cellA = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! EventListTableViewCell
                                    
                                    expect(self.eventListTableViewCellPresenter.lastReceivedEvent).to(beIdenticalTo(eventA))
                                    expect(self.eventListTableViewCellPresenter.lastReceivedCell).to(beIdenticalTo(cellA))
                                    
                                    var cellB = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! EventListTableViewCell
                                    
                                    expect(self.eventListTableViewCellPresenter.lastReceivedEvent).to(beIdenticalTo(eventB))
                                    expect(self.eventListTableViewCellPresenter.lastReceivedCell).to(beIdenticalTo(cellB))
                                }
                                
                                it("styles the cells from the theme") {
                                    var cell = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0)) as! EventListTableViewCell
                                    
                                    expect(cell.nameLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                                    expect(cell.addressLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                                    expect(cell.attendeesLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))
                                    
                                    expect(cell.nameLabel.textColor).to(equal(UIColor.yellowColor()))
                                    expect(cell.addressLabel.textColor).to(equal(UIColor.yellowColor()))
                                    expect(cell.attendeesLabel.textColor).to(equal(UIColor.yellowColor()))
                                }
                            }
                            
                            describe("making a subsequent search") {
                                beforeEach {
                                    self.subject.zipCodeTextField.text = "11111"
                                    
                                    self.subject.eventSearchButton.tap()
                                }
                                
                                it("should hide the results table view") {
                                    expect(self.subject.resultsTableView.hidden).to(beTrue())
                                }
                                
                                
                                it("should show the spinner") {
                                    expect(self.subject.loadingActivityIndicatorView.isAnimating()).to(beTrue())
                                }
                                
                                it("should ask the events repository for events within 50 miles") {
                                    expect(self.eventRepository.lastReceivedZipCode).to(equal("11111"))
                                    expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
