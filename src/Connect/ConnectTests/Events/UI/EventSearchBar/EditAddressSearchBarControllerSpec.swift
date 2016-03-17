import Quick
import Nimble

@testable import Connect

class EditAddressSearchBarControllerSpec: QuickSpec {
    override func spec() {
       describe("EditAddressSearchBarController") {
            var subject: EditAddressSearchBarController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var radiusDataSource: MockRadiusDataSource!
            var zipCodeValidator: FakeZipCodeValidator!
            var searchBarStylist: MockSearchBarStylist!
            var resultQueue: FakeOperationQueue!
            var workerQueue: FakeOperationQueue!
            var analyticsService: FakeAnalyticsService!

            var window: UIWindow!
            var delegate: MockEditAddressSearchBarControllerDelegate!

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                radiusDataSource = MockRadiusDataSource()
                zipCodeValidator = FakeZipCodeValidator()
                searchBarStylist = MockSearchBarStylist()
                resultQueue = FakeOperationQueue()
                workerQueue = FakeOperationQueue()
                analyticsService = FakeAnalyticsService()

                subject = EditAddressSearchBarController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    radiusDataSource: radiusDataSource,
                    zipCodeValidator: zipCodeValidator,
                    searchBarStylist: searchBarStylist,
                    resultQueue: resultQueue,
                    workerQueue: workerQueue,
                    analyticsService: analyticsService,
                    theme: EventsSearchBarFakeTheme()
                )

                window = UIWindow()
                window.addSubview(subject.view)

                delegate = MockEditAddressSearchBarControllerDelegate()
                subject.delegate = delegate
            }

            describe("when the view loads") {
                it("has the search bar as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBar))
                }

                it("has the search button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchButton))
                }

                it("disables the search button by default") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.enabled) == false
                }

                it("has the cancel button as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.cancelButton))
                }

                it("has the correct text for the search button") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.titleForState(.Normal)) == "Search"
                }

                it("has the correct text for the cancel button") {
                    subject.view.layoutSubviews()

                    expect(subject.cancelButton.titleForState(.Normal)) == "Cancel"
                }

                it("sets the placeholder text") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.placeholder) == "ZIP Code"
                }

                it("configures the search bar keyboard to be a number pad") {
                    expect(subject.searchBar.keyboardType).to(equal(UIKeyboardType.NumberPad))
                }

                it("sets the accessibility label on the search bar") {
                    subject.view.layoutSubviews()

                    expect(subject.searchBar.accessibilityLabel) == "ZIP Code"
                }

                it("styles the page components with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.searchButton.titleColorForState(.Normal)) == UIColor(rgba: "#111111")
                    expect(subject.searchButton.titleColorForState(.Disabled)) == UIColor(rgba: "#abcdef")
                    expect(subject.searchButton.titleLabel!.font) == UIFont.boldSystemFontOfSize(4444)

                    expect(subject.cancelButton.titleColorForState(.Normal)) == UIColor(rgba: "#111111")
                    expect(subject.cancelButton.titleColorForState(.Disabled)) == UIColor(rgba: "#abcdef")
                    expect(subject.cancelButton.titleLabel!.font) == UIFont.boldSystemFontOfSize(4444)
                }


                describe("using the search bar stylist") {
                    beforeEach {
                        subject.view.layoutSubviews()
                    }

                    itBehavesLike("a controller that applies the search bar stylist") { [
                        "searchBar": subject.searchBar,
                        "containerView": subject.view,
                        "searchBarStylist": searchBarStylist
                        ] }
                }
            }


            describe("when the view will appear") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("becomes first responder") {
                    subject.viewWillAppear(true)

                    expect(subject.searchBar.isFirstResponder()) == true
                }
            }

            describe("tapping the search button") {
                beforeEach {
                    subject.view.layoutSubviews()
                    subject.searchButton.enabled = true
                }

                it("tells the events near address use case to start a new search with the radius from the data source") {
                    radiusDataSource.returnedCurrentMilesValue = 42.1
                    subject.searchBar.text = "nice place"

                    subject.searchButton.tap()

                    workerQueue.lastReceivedBlock()

                    expect(eventsNearAddressUseCase.lastSearchedAddress) == "nice place"
                    expect(eventsNearAddressUseCase.lastSearchedRadius) == 42.1
                }

                it("should log an event via the analytics service") {
                    subject.searchBar.text = "track me"
                    radiusDataSource.returnedCurrentMilesValue = 42

                    subject.searchButton.tap()
                    workerQueue.lastReceivedBlock()

                    expect(analyticsService.lastSearchQuery).to(equal("track me|42.0"))
                    expect(analyticsService.lastSearchContext).to(equal(AnalyticsSearchContext.Events))
                }
            }

            describe("tapping the cancel button") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("notifies the delegate") {
                    subject.cancelButton.tap()

                    expect(delegate.didCancelWithController) === subject
                }

                it("should log an event via the analytics service") {
                    subject.cancelButton.tap()

                    expect(analyticsService.lastCustomEventName).to(equal("Cancelled edit address on Events"))
                }

                context("after having began editing an existing search") {
                    it("restores the text to the pre-edit state") {
                        eventsNearAddressUseCase.simulateStartOfFetch()
                        resultQueue.lastReceivedBlock()

                        subject.searchBar.text = "this will go away"

                        subject.cancelButton.tap()

                        expect(subject.searchBar.text) == "simulated address"
                    }

                    context("and then editing an address after a subsequent nearby search") {
                        beforeEach {
                            eventsNearAddressUseCase.simulateStartOfFetch()
                            resultQueue.lastReceivedBlock()
                            subject.cancelButton.tap()
                        }

                        it("sets the text to blank") {
                            nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(123)
                            resultQueue.lastReceivedBlock()

                            expect(subject.searchBar.text) == ""
                        }
                    }
                }
            }

            describe("editing an address") {
                var searchBar: UISearchBar!

                beforeEach {
                    subject.view.layoutSubviews()
                    searchBar = subject.searchBar
                    searchBar.becomeFirstResponder()
                }

                context("and the updated zipcode is determined to be valid by the validator") {
                    it("enables the search button") {
                        searchBar.text = "9021"
                        subject.searchButton.enabled = false

                        zipCodeValidator.returnedValidationResult = true
                        let range = NSRange(location: 3, length: 0)
                        searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "1")

                        expect(zipCodeValidator.lastReceivedZipCode) == "90211"
                        expect(subject.searchButton.enabled) == true
                    }
                }

                context("and the updated zipcode is determined to be invalid by the validator") {
                    it("enables the search button") {
                        searchBar.text = "9021"
                        subject.searchButton.enabled = true

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
                        searchBar.delegate?.searchBar!(searchBar, textDidChange: "90211")

                        searchBar.text = "90211"
                        zipCodeValidator.returnedValidationResult = false

                        searchBar.delegate?.searchBar!(searchBar, shouldChangeTextInRange: range, replacementText: "1")

                        expect(subject.searchButton.enabled) == true
                    }
                }

                context("and the user clears the text field") {
                    it("disables the search button") {
                        subject.searchButton.enabled = true

                        searchBar.delegate?.searchBar!(searchBar, textDidChange: "")

                        expect(subject.searchButton.enabled) == false
                    }
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when a nearby search is initiated") {
                    it("sets the text of the search bar to blank") {
                        subject.searchBar.text = "some location"

                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(200)
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.text) == ""
                    }

                    it("disables the search button") {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(200)
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchButton.enabled) == false
                    }
                }
            }

            describe("as a events near address use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when a search is initiated") {
                    it("sets the text of the search bar to that of the search") {
                        subject.searchBar.text = "some location"

                        eventsNearAddressUseCase.simulateStartOfFetch()
                        resultQueue.lastReceivedBlock()

                        expect(subject.searchBar.text) == "simulated address"
                    }
                }
            }
        }
    }
}

private class MockEditAddressSearchBarControllerDelegate: EditAddressSearchBarControllerDelegate {
    var didCancelWithController: EditAddressSearchBarController?
    func editAddressSearchBarControllerDidCancel(controller: EditAddressSearchBarController) {
        didCancelWithController = controller
    }
}
