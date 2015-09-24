import UIKit
import Quick
import Nimble
import berniesanders


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

class ConnectControllerSpec : QuickSpec {
    var subject : ConnectController!
    var eventRepository : FakeEventRepository!
    
    override func spec() {
        beforeEach {
            self.eventRepository = FakeEventRepository()
            
            self.subject = ConnectController(
                eventRepository: self.eventRepository,
                theme: ConnectFakeTheme()
            )
        }
        
       describe("ConnectController") {
            it("has the correct tab bar title") {
                expect(self.subject.title).to(equal("Connect"))
            }
            
            it("has the correct navigation item title") {
                expect(self.subject.navigationItem.title).to(equal("Connect"))
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
            
            describe("making a search by zip code") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                xit("has the correct range of values in the radius picker") {
                    
                }
                
                xit("has the correct default value for the radius picker") {
                    
                }
                
                it("should add its view components as subviews") {
                    var subViews = self.subject.view.subviews as! [UIView]
                    
                    expect(contains(subViews, self.subject.zipCodeTextField)).to(beTrue())
                    expect(contains(subViews, self.subject.eventSearchButton)).to(beTrue())
                    expect(contains(subViews, self.subject.noResultsLabel)).to(beTrue())
                    expect(contains(subViews, self.subject.resultsTableView)).to(beTrue())
                }
                
                it("should leave the table view hidden") {
                    expect(self.subject.resultsTableView.hidden).to(beTrue())
                }
                
                it("should hide the no results label by default") {
                    expect(self.subject.noResultsLabel.hidden).to(beTrue())
                }
                
                context("when entering an invalid zip code and range") {
                    xit("should display an error") {
                        
                    }
                    
                    xit("should not make a search") {
                        
                    }
                }
                
                context("when entering a valid zip code") {
                    beforeEach {
                        self.subject.view.layoutSubviews()
                        
                        self.subject.zipCodeTextField.text = "90210"
                        self.subject.eventSearchButton.tap()
                    }
                    
                    xit("should show a spinner") {
                        
                    }
                    
                    it("should ask the events repository for events within 50 miles") {
                        expect(self.eventRepository.lastReceivedZipCode).to(equal("90210"))
                        expect(self.eventRepository.lastReceivedRadiusMiles).to(equal(50.0))
                    }
                    
                    context("when the search completes succesfully") {
                        context("with no results") {
                            beforeEach {
                                var events : Array<Event> = []
                                self.eventRepository.lastCompletionBlock!(events)
                            }
                            
                            xit("should hide the spinner") {
                                
                            }
                            
                            it("should display a no results message") {
                                expect(self.subject.noResultsLabel.hidden).to(beFalse())
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
                                
                                xit("should show the spinner") {
                                    
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

                            
                            xit("should hide the spinner") {
                                
                            }
                            
                            it("should leave the no results message hidden") {
                                expect(self.subject.noResultsLabel.hidden).to(beTrue())
                            }
                            
                            it("should show the results table") {
                                expect(self.subject.resultsTableView.hidden).to(beFalse())
                            }
                            

                            describe("the results table") {
                                it("has content from the search results") {
                                    expect(self.subject.resultsTableView.numberOfSections()).to(equal(1))
                                    expect(self.subject.resultsTableView.numberOfRowsInSection(0)).to(equal(2))
                                    
                                    var cellA = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! EventListTableViewCell
                                    expect(cellA.nameLabel.text).to(equal("Bigtime Bernie BBQ"))
                                    expect(cellA.addressLabel.text).to(equal("Beverley Hills, CA - 90210"))
                                    expect(cellA.attendeesLabel.text).to(equal("2 of RSVP: 10"))
                                    
                                    var cellB = self.subject.resultsTableView.dataSource!.tableView(self.subject.resultsTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! EventListTableViewCell
                                    expect(cellB.nameLabel.text).to(equal("Slammin' Sanders Salsa Serenade"))
                                    expect(cellB.addressLabel.text).to(equal("Beverley Hills, CA - 90210"))
                                    expect(cellB.attendeesLabel.text).to(equal("2 of RSVP: 10"))
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

                                
                                xit("should show the spinner") {
                                    
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
