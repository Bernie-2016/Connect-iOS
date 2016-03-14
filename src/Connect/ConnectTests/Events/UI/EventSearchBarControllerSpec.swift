import Quick
import Nimble

@testable import Connect

class EventSearchBarControllerSpec: QuickSpec {
    override func spec() {
        describe("EventSearchBarController") {
            var subject: EventSearchBarController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var resultQueue: FakeOperationQueue!
            let theme = EventsSearchBarFakeTheme()

            var window : UIWindow!

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                resultQueue = FakeOperationQueue()

                subject = EventSearchBarController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    resultQueue: resultQueue,
                    theme: theme
                )

                window = UIWindow()
                window.addSubview(subject.view)
                window.makeKeyAndVisible()
            }

            it("adds itself as an observer of the nearby events use case on initialization") {
                expect(nearbyEventsUseCase.observers.first as? EventSearchBarController) === subject
            }

            describe("when the view loads") {
                it("has the search bar as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBar))
                }

                it("has the cancel button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.cancelButton))
                }

                it("has the search button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchButton))
                }

                it("has the correct text for the search button for the zip code entry field") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.titleForState(.Normal)).to(equal("Search"))
                }

                it("has the correct text for the cancel button") {
                    subject.view.layoutSubviews()

                    expect(subject.cancelButton.titleForState(.Normal)).to(equal("Cancel"))
                }

                it("styles the page components with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.view.backgroundColor).to(equal(UIColor.greenColor()))

                    var searchBarTextFieldTested = false
                    if let textField = subject.searchBar.valueForKey("searchField") as? UITextField {                               searchBarTextFieldTested = true
                        expect(textField.backgroundColor) == UIColor.brownColor()
                        expect(textField.font).to(equal(UIFont.boldSystemFontOfSize(4444)))
                        expect(textField.textColor).to(equal(UIColor.redColor()))
                        expect(textField.layer.cornerRadius).to(equal(100.0))
                        expect(textField.layer.borderWidth).to(equal(200.0))

                        let borderColor = UIColor(CGColor: textField.layer.borderColor!)
                        expect(borderColor).to(equal(UIColor.orangeColor()))
                    }
                    expect(searchBarTextFieldTested) == true

                    expect(subject.searchButton.titleColorForState(.Normal)).to(equal(UIColor(rgba: "#111111")))
                    expect(subject.searchButton.titleColorForState(.Disabled)).to(equal(UIColor(rgba: "#abcdef")))
                    expect(subject.searchButton.titleLabel!.font).to(equal(UIFont.boldSystemFontOfSize(4444)))

                    expect(subject.cancelButton.titleColorForState(.Normal)).to(equal(UIColor(rgba: "#111111")))
                    expect(subject.cancelButton.titleColorForState(.Disabled)).to(equal(UIColor(rgba: "#abcdef")))
                    expect(subject.cancelButton.titleLabel!.font).to(equal(UIFont.boldSystemFontOfSize(4444)))
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case has started finding events, on the result queue") {
                    it("sets the search bar text to Locating") {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(666)

                        expect(subject.searchBar.placeholder).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "Locating..."
                    }
                }

                context("when the use case has found nearby events") {
                    it("sets the search bar text to Current Location, on the result queue") {
                        let searchResult = EventSearchResult(events: [])
                        nearbyEventsUseCase.simulateFindingEvents(searchResult)

                        expect(subject.searchBar.placeholder).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "Current Location"
                    }

                    describe("and then the user edits the location") {
                        beforeEach {
                            let searchResult = EventSearchResult(events: [])
                            nearbyEventsUseCase.simulateFindingEvents(searchResult)

                            resultQueue.lastReceivedBlock()
                        }

                        itBehavesLike("the standard search bar editing behavior") {
                            [
                                "subject": subject,
                                "eventsNearAddressUseCase":  eventsNearAddressUseCase
                            ]
                        }
                    }
                }

                context("when the use case found no nearby events") {
                    it("sets the search bar placeholder text to Current Location, on the result queue") {
                        nearbyEventsUseCase.simulateFindingNoEvents()

                        expect(subject.searchBar.placeholder).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "Current Location"
                    }

                    describe("and then the user edits the location") {
                        beforeEach {
                            nearbyEventsUseCase.simulateFindingNoEvents()
                            resultQueue.lastReceivedBlock()
                        }

                        itBehavesLike("the standard search bar editing behavior") {
                            [
                                "subject": subject,
                                "eventsNearAddressUseCase":  eventsNearAddressUseCase
                            ]
                        }
                    }
                }
            }
        }
    }
}

class SearchBarSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("the standard search bar editing behavior") { (sharedExampleContext: SharedExampleContext) in
            var subject: EventSearchBarController!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!

            beforeEach {
                subject = sharedExampleContext()["subject"] as! EventSearchBarController
                eventsNearAddressUseCase = sharedExampleContext()["eventsNearAddressUseCase"] as! MockEventsNearAddressUseCase
            }

            it("updates the placeholder text") {
                subject.searchBar.becomeFirstResponder()

                expect(subject.searchBar.placeholder) == "ZIP Code"
            }

            it("allows the search bar to be first responder") {
                subject.searchBar.becomeFirstResponder()

                expect(subject.searchBar.isFirstResponder()) == true
            }

            describe("and then the user cancels") {
                beforeEach {
                    subject.searchBar.becomeFirstResponder()
                }

                it("resigns first responder") {
                    subject.cancelButton.tap()

                    expect(subject.searchBar.isFirstResponder()) == false
                }

                it("resets the placeholder text") {
                    subject.cancelButton.tap()

                    expect(subject.searchBar.placeholder) == "Current Location"
                }
            }

            describe("and then the user enters a zipcode") {
                beforeEach {
                    subject.searchBar.becomeFirstResponder()
                }

                context("that is valid") {
                    describe("and the user taps search") {
                        beforeEach {
                            subject.searchBar.text = "90210"
                        }

                        it("calls the find events near address use case with a default radius") {
                            subject.searchButton.tap()

                            expect(eventsNearAddressUseCase.lastSearchedAddress) == "90210"
                            expect(eventsNearAddressUseCase.lastSearchedRadius) == 10.0
                        }

                        it("resigns first responder") {
                            subject.searchButton.tap()

                            expect(subject.searchBar.isFirstResponder()) == false
                        }

                        it("sets the search bar placeholder text to the entered text") {
                            subject.searchButton.tap()

                            expect(subject.searchBar.placeholder) == "90210"
                        }

                        it("nils out the search bar text") {
                            subject.searchButton.tap()

                            expect(subject.searchBar.text) == ""
                        }
                    }
                }
            }
        }
    }
}

private class EventsSearchBarFakeTheme: FakeTheme {
    override func eventsSearchBarBackgroundColor() -> UIColor { return UIColor.greenColor() }
    override func eventsSearchBarFont() -> UIFont { return UIFont.boldSystemFontOfSize(4444) }
    override func defaultButtonDisabledTextColor() -> UIColor { return UIColor(rgba: "#abcdef") }
    override func navigationBarButtonTextColor()  -> UIColor { return UIColor(rgba: "#111111") }
    override func eventsZipCodeTextColor() -> UIColor { return UIColor.redColor() }
    override func eventsZipCodeBackgroundColor() -> UIColor { return UIColor.brownColor() }
    override func eventsZipCodeBorderColor() -> UIColor { return UIColor.orangeColor() }
    override func eventsZipCodeCornerRadius() -> CGFloat { return 100.0 }
    override func eventsZipCodeBorderWidth() -> CGFloat { return 200.0 }
    override func eventsZipCodePlaceholderTextColor() -> UIColor { return UIColor(rgba: "#222222") } // not explicitly tested
}

