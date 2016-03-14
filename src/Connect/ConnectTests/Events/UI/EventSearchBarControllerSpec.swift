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
            var zipCodeValidator: FakeZipCodeValidator!

            var window : UIWindow!

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                resultQueue = FakeOperationQueue()
                zipCodeValidator = FakeZipCodeValidator()

                subject = EventSearchBarController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    resultQueue: resultQueue,
                    zipCodeValidator: zipCodeValidator,
                    theme: theme)

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

                it("configures the search bar keyboard to be a number pad") {
                    expect(subject.searchBar.keyboardType).to(equal(UIKeyboardType.NumberPad))
                }

                it("configures the accessibility label for the search bar") {
                    expect(subject.searchBar.accessibilityLabel).to(equal("ZIP Code"))
                }

                it("should hide the search button by default") {
                    expect(subject.searchButton.hidden) == true
                }

                it("should hide the cancel button by default") {
                    expect(subject.cancelButton.hidden) == true
                }

                it("initially disables the search button") {
                    expect(subject.searchButton.enabled) == false
                }

                it("has the correct text for the search button for the zip code entry field") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.titleForState(.Normal)) == "Search"
                }

                it("has the correct text for the cancel button") {
                    subject.view.layoutSubviews()

                    expect(subject.cancelButton.titleForState(.Normal)) == "Cancel"
                }

                it("styles the page components with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.view.backgroundColor) == UIColor.greenColor()

                    var searchBarTextFieldTested = false
                    if let textField = subject.searchBar.valueForKey("searchField") as? UITextField {                               searchBarTextFieldTested = true
                        expect(textField.backgroundColor) == UIColor.brownColor()
                        expect(textField.font) == UIFont.boldSystemFontOfSize(4444)
                        expect(textField.textColor) == UIColor.redColor()
                        expect(textField.layer.cornerRadius) == 100.0
                        expect(textField.layer.borderWidth) == 200.0

                        let borderColor = UIColor(CGColor: textField.layer.borderColor!)
                        expect(borderColor) == UIColor.orangeColor()
                    }
                    expect(searchBarTextFieldTested) == true

                    expect(subject.searchButton.titleColorForState(.Normal)) == UIColor(rgba: "#111111")
                    expect(subject.searchButton.titleColorForState(.Disabled)) == UIColor(rgba: "#abcdef")
                    expect(subject.searchButton.titleLabel!.font) == UIFont.boldSystemFontOfSize(4444)

                    expect(subject.cancelButton.titleColorForState(.Normal)) == UIColor(rgba: "#111111")
                    expect(subject.cancelButton.titleColorForState(.Disabled)) == UIColor(rgba: "#abcdef")
                    expect(subject.cancelButton.titleLabel!.font) == UIFont.boldSystemFontOfSize(4444)
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case has started finding events") {
                    it("sets the search bar placeholder to Locating, on the result queue") {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(666)

                        expect(subject.searchBar.placeholder) != "Locating..."
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "Locating..."
                    }

                    it("disables user interaction") {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(666)
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.userInteractionEnabled) == false
                    }

                    it("makes the search bar transparent") {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(666)
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.alpha) < 1.0
                    }
                }

                context("when the use case has an error finding nearby events") {
                    beforeEach {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(666)
                        resultQueue.lastReceivedBlock()
                    }

                    it("sets the search bar placeholder to zip code, on the result queue") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))

                        expect(subject.searchBar.placeholder) != "ZIP Code"
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "ZIP Code"
                    }

                    it("enables user interaction") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.userInteractionEnabled) == true
                    }

                    it("makes the search bar transparent") {
                        nearbyEventsUseCase.simulateFailingToFindEvents(.FindingLocationError(.PermissionsError))
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.alpha) == 1.0
                    }
                }

                context("when the use case has found nearby events") {
                    beforeEach {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(666)
                        resultQueue.lastReceivedBlock()
                    }

                    it("sets the search bar text to Current Location, on the result queue") {
                        let searchResult = EventSearchResult(events: [])
                        nearbyEventsUseCase.simulateFindingEvents(searchResult)

                        expect(subject.searchBar.placeholder) != "Current Location"

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "Current Location"
                    }

                    it("enables user interaction") {
                        let searchResult = EventSearchResult(events: [])
                        nearbyEventsUseCase.simulateFindingEvents(searchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.userInteractionEnabled) == true
                    }

                    it("makes the search bar transparent") {
                        let searchResult = EventSearchResult(events: [])
                        nearbyEventsUseCase.simulateFindingEvents(searchResult)
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.alpha) == 1.0
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
                                "eventsNearAddressUseCase":  eventsNearAddressUseCase,
                                "zipCodeValidator": zipCodeValidator
                            ]
                        }
                    }
                }

                context("when the use case found no nearby events") {
                    beforeEach {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(666)
                        resultQueue.lastReceivedBlock()
                    }

                    it("sets the search bar placeholder text to Current Location, on the result queue") {
                        nearbyEventsUseCase.simulateFindingNoEvents()

                        expect(subject.searchBar.placeholder) != "Current Location"

                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.placeholder) == "Current Location"
                    }

                    it("enables user interaction") {
                        nearbyEventsUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.userInteractionEnabled) == true
                    }

                    it("makes the search bar transparent") {
                        nearbyEventsUseCase.simulateFindingNoEvents()
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.alpha) == 1.0
                    }

                    describe("and then the user edits the location") {
                        beforeEach {
                            nearbyEventsUseCase.simulateFindingNoEvents()
                            resultQueue.lastReceivedBlock()
                        }

                        it("sets the text to blank on entry") {
                            let searchBar = subject.searchBar

                            searchBar.becomeFirstResponder()

                            expect(searchBar.text) == ""
                        }

                        itBehavesLike("the standard search bar editing behavior") {
                            [
                                "subject": subject,
                                "eventsNearAddressUseCase":  eventsNearAddressUseCase,
                                "zipCodeValidator": zipCodeValidator
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
            var searchBar: UISearchBar!
            var zipCodeValidator: FakeZipCodeValidator!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!

            beforeEach {
                subject = sharedExampleContext()["subject"] as! EventSearchBarController
                searchBar = subject.searchBar
                zipCodeValidator = sharedExampleContext()["zipCodeValidator"] as! FakeZipCodeValidator
                eventsNearAddressUseCase = sharedExampleContext()["eventsNearAddressUseCase"] as! MockEventsNearAddressUseCase
            }

            it("updates the placeholder text") {
                searchBar.becomeFirstResponder()

                expect(searchBar.placeholder) == "ZIP Code"
            }

            it("allows the search bar to be first responder") {
                searchBar.becomeFirstResponder()

                expect(searchBar.isFirstResponder()) == true
            }

            describe("and then the user cancels") {
                beforeEach {
                    searchBar.becomeFirstResponder()
                }

                it("resigns first responder") {
                    subject.cancelButton.tap()

                    expect(searchBar.isFirstResponder()) == false
                }

                it("resets the placeholder text") {
                    subject.cancelButton.tap()

                    expect(searchBar.placeholder) == "Current Location"
                }
            }

            describe("and then the user enters a zipcode") {
                beforeEach {
                    searchBar.becomeFirstResponder()
                }

                describe("and then the user cancels") {
                    beforeEach {
                        searchBar.text = "9021"
                        zipCodeValidator.returnedValidationResult = true
                        let range = NSRange(location: 3, length: 0)
                        searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "1")
                    }

                    it("resigns first responder") {
                        subject.cancelButton.tap()

                        expect(searchBar.isFirstResponder()) == false
                    }

                    it("resets the placeholder text") {
                        subject.cancelButton.tap()

                        expect(searchBar.placeholder) == "Current Location"
                    }

                    it("sets the text to empty") {
                        subject.cancelButton.tap()

                        expect(searchBar.text) == ""
                    }

                    it("should hide the search button") {
                        subject.cancelButton.tap()

                        expect(subject.searchButton.hidden) == true
                    }

                    it("should hide the cancel button") {
                        subject.cancelButton.tap()

                        expect(subject.cancelButton.hidden) == true
                    }

                    it("should re-validate the original address content and use the validation result on the text field") {
                        zipCodeValidator.returnedValidationResult = true

                        subject.cancelButton.tap()

                        expect(zipCodeValidator.lastReceivedZipCode) == "Current Location"
                        expect(subject.searchButton.enabled) == true
                    }
                }

                context("and the updated zipcode is determined to be valid by the validator") {
                    it("enables the search button") {
                        searchBar.text = "9021"
                        zipCodeValidator.returnedValidationResult = true
                        let range = NSRange(location: 3, length: 0)
                        searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "1")

                        expect(zipCodeValidator.lastReceivedZipCode) == "90211"
                        expect(subject.searchButton.enabled) == true
                    }

                    describe("and the user taps search") {
                        beforeEach {
                            searchBar.text = "9021"
                            zipCodeValidator.returnedValidationResult = true
                            let range = NSRange(location: 3, length: 0)
                            searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "0")
                            searchBar.text = "90210"
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

                        it("should hide the search button") {
                            subject.searchButton.tap()

                            expect(subject.searchButton.hidden) == true
                        }

                        it("should hide the cancel button") {
                            subject.searchButton.tap()

                            expect(subject.cancelButton.hidden) == true
                        }
                    }

                    context("and the updated zipcode is invalid") {
                        it("disables the search button") {
                            searchBar.text = "9021"
                            zipCodeValidator.returnedValidationResult = false
                            let range = NSRange(location: 3, length: 0)
                            searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "1")

                            expect(zipCodeValidator.lastReceivedZipCode) == "90211"
                            expect(subject.searchButton.enabled) == false
                        }
                    }

                    context("and user tries to enter a zipcode more than 5 characters in length") {
                        it("prevents the user from entering more characters") {
                            searchBar.text = "9021"
                            zipCodeValidator.returnedValidationResult = true
                            let range = NSRange(location: 3, length: 0)

                            let shouldChange = searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "12")

                            expect(shouldChange) == false
                        }

                        it("leaves the search button enabled if the existing text was valid") {
                            let range = NSRange(location: 4, length: 0)

                            searchBar.text = "9021"

                            zipCodeValidator.returnedValidationResult = true

                            searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "1")

                            searchBar.text = "90211"
                            zipCodeValidator.returnedValidationResult = false

                            searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "1")

                            expect(subject.searchButton.enabled) == true
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

private class FakeZipCodeValidator: ZipCodeValidator {
    var lastReceivedZipCode: NSString!
    var returnedValidationResult = true

    func reset() {
        lastReceivedZipCode = nil
    }

    private func validate(zip: String) -> Bool {
        lastReceivedZipCode = zip
        return returnedValidationResult
    }
}

