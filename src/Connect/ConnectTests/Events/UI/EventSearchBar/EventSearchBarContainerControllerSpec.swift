import Quick
import Nimble

@testable import Connect

class EventSearchBarContainerControllerSpec: QuickSpec {
    override func spec() {
        describe("EventSearchBarContainerController") {
            var subject: EventSearchBarContainerController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var nearbyEventsLoadingSearchBarController: UIViewController!
            var nearbyEventsSearchBarController: MockNearbyEventsSearchBarController!
            var eventsNearAddressSearchBarController: MockEventsNearAddressSearchBarController!
            var editAddressSearchBarController: MockEditAddressSearchBarController!
            var nearbyEventsFilterController: MockNearbyEventsFilterController!
            var eventsNearAddressFilterController: MockEventsNearAddressFilterController!
            var childControllerBuddy: MockChildControllerBuddy!
            var resultQueue: FakeOperationQueue!

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                nearbyEventsLoadingSearchBarController = UIViewController()
                nearbyEventsSearchBarController = MockNearbyEventsSearchBarController()
                eventsNearAddressSearchBarController = MockEventsNearAddressSearchBarController()
                editAddressSearchBarController = MockEditAddressSearchBarController()
                nearbyEventsFilterController = MockNearbyEventsFilterController()
                eventsNearAddressFilterController = MockEventsNearAddressFilterController()
                childControllerBuddy = MockChildControllerBuddy()
                resultQueue = FakeOperationQueue()

                subject = EventSearchBarContainerController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    nearbyEventsLoadingSearchBarController: nearbyEventsLoadingSearchBarController,
                    nearbyEventsSearchBarController: nearbyEventsSearchBarController,
                    eventsNearAddressSearchBarController: eventsNearAddressSearchBarController,
                    editAddressSearchBarController: editAddressSearchBarController,
                    nearbyEventsFilterController: nearbyEventsFilterController,
                    eventsNearAddressFilterController: eventsNearAddressFilterController,
                    childControllerBuddy: childControllerBuddy,
                    resultQueue: resultQueue
                )
            }

            describe("when the view loads") {
                it("adds the nearby events loading search bar controller by default") {
                    subject.view.layoutSubviews()

                    let addCall = childControllerBuddy.addCalls.first!
                    expect(addCall.addController) === nearbyEventsLoadingSearchBarController
                    expect(addCall.parentController) === subject
                    expect(addCall.containerView) === subject.view
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when the use case has started fetching nearby events") {
                    it("shows the nearby events loading controller, on the result queue") {
                        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(9000.0)

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                describe("when the use case has found nearby search bar") {
                    it("shows the nearby events search bar controller") {
                        nearbyEventsUseCase.simulateFindingEvents(EventSearchResult(events: []))

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === nearbyEventsSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                describe("when the use case has found no nearby search bar") {
                    it("shows the nearby events search bar controller") {
                        nearbyEventsUseCase.simulateFindingNoEvents()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === nearbyEventsSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                describe("when the use case has failed to find nearby search bar") {
                    it("shows the nearby events search bar controller") {
                        let error = NearbyEventsUseCaseError.FindingLocationError(.PermissionsError)
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === nearbyEventsSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }

            describe("as an events near address use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when the use case has started fetching events") {
                    it("shows the events near address search bar controller") {
                        eventsNearAddressUseCase.simulateStartOfFetch()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === eventsNearAddressSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                describe("when the use case has found search bar") {
                    it("shows the events near address search bar controller") {
                        eventsNearAddressUseCase.simulateFindingEvents(EventSearchResult(events: []))

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === eventsNearAddressSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                describe("when the use case has found no search bar") {
                    it("shows the events near address search bar controller") {
                        eventsNearAddressUseCase.simulateFindingNoEvents()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === eventsNearAddressSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                describe("when the use case has failed to find search bar") {
                    it("shows the events near address search bar controller") {
                        let error = EventsNearAddressUseCaseError.GeocodingError(NSError(domain: "", code: 666, userInfo: nil))
                        eventsNearAddressUseCase.simulateFailingToFindEvents(error)

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === eventsNearAddressSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }

            describe("as a nearby events search bar controller delegate") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when the user has began editing") {
                    it("shows the edit address controller") {
                        nearbyEventsSearchBarController.simulateEdit()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === editAddressSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }

                    describe("and the user then cancels editing") {
                        beforeEach {
                            nearbyEventsSearchBarController.simulateEdit()
                            resultQueue.lastReceivedBlock()
                        }

                        it("shows the nearby events search bar controller") {
                            editAddressSearchBarController.simulateCancel()

                            expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController

                            resultQueue.lastReceivedBlock()

                            expect(childControllerBuddy.lastOldSwappedController) === editAddressSearchBarController
                            expect(childControllerBuddy.lastNewSwappedController) === nearbyEventsSearchBarController
                            expect(childControllerBuddy.lastParentSwappedController) === subject
                        }
                    }
                }

                describe("when the user has began changing the filter") {
                    it("shows the nearby filter controller") {
                        nearbyEventsSearchBarController.simulateFilter()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === nearbyEventsFilterController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }

            describe("as a nearby events filter delegate") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when the user cancels") {
                    it("shows the nearby events search bar controller") {
                        nearbyEventsFilterController.simulateCancel()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === nearbyEventsSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }

            describe("as an events near address search bar controller delegate") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when the user has began editing") {
                    it("shows the edit address controller") {
                        eventsNearAddressSearchBarController.simulateEdit()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === editAddressSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }

                    describe("and the user then cancels editing") {
                        beforeEach {
                            eventsNearAddressSearchBarController.simulateEdit()
                            resultQueue.lastReceivedBlock()
                        }

                        it("shows the events near address search bar controller") {
                            editAddressSearchBarController.simulateCancel()

                            expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController

                            resultQueue.lastReceivedBlock()

                            expect(childControllerBuddy.lastOldSwappedController) === editAddressSearchBarController
                            expect(childControllerBuddy.lastNewSwappedController) === eventsNearAddressSearchBarController
                            expect(childControllerBuddy.lastParentSwappedController) === subject
                        }
                    }
                }

                describe("when the user has began changing the filter") {
                    it("shows the near address filter controller") {
                        eventsNearAddressSearchBarController.simulateFilter()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === eventsNearAddressFilterController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }

            describe("as an events near address filter delegate") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when the user cancels") {
                    it("shows the events near address search bar controller") {
                        eventsNearAddressFilterController.simulateCancel()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === eventsNearAddressSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }

            describe("as an edit address controller delegate") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when called out of order") {
                    it("defaults to showing the nearby events search bar controller") {
                        editAddressSearchBarController.simulateCancel()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === nearbyEventsLoadingSearchBarController
                        expect(childControllerBuddy.lastNewSwappedController) === nearbyEventsSearchBarController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }
        }
    }
}


class MockNearbyEventsSearchBarController: NearbyEventsSearchBarController {
    init() {
        super.init(searchBarStylist: MockSearchBarStylist(), radiusDataSource: MockRadiusDataSource(), theme: SearchBarFakeTheme())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func simulateEdit() {
        delegate!.nearbyEventsSearchBarControllerDidBeginEditing(self)
    }

    func simulateFilter() {
        delegate!.nearbyEventsSearchBarControllerDidBeginFiltering(self)
    }
}

class MockEventsNearAddressSearchBarController: EventsNearAddressSearchBarController {
    init() {
        super.init(
            searchBarStylist: MockSearchBarStylist(),
            eventsNearAddressUseCase: MockEventsNearAddressUseCase(),
            resultQueue: FakeOperationQueue(),
            radiusDataSource: MockRadiusDataSource(),
            theme: SearchBarFakeTheme()
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func simulateEdit() {
        delegate!.eventsNearAddressSearchBarControllerDidBeginEditing(self)
    }

    func simulateFilter() {
        delegate!.eventsNearAddressSearchBarControllerDidBeginFiltering(self)
    }

}

class MockNearbyEventsFilterController: NearbyEventsFilterController {
    init() {
        super.init(
            nearbyEventsUseCase: MockNearbyEventsUseCase(),
            radiusDataSource: MockRadiusDataSource(),
            workerQueue: FakeOperationQueue(),
            theme: SearchBarFakeTheme()
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func simulateCancel() {
        delegate!.nearbyEventsFilterControllerDidCancel(self)
    }
}

class MockEventsNearAddressFilterController: EventsNearAddressFilterController {
    init() {
        super.init(
            eventsNearAddressUseCase: MockEventsNearAddressUseCase(),
            radiusDataSource: MockRadiusDataSource(),
            workerQueue: FakeOperationQueue(),
            resultQueue: FakeOperationQueue(),
            theme: SearchBarFakeTheme()
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func simulateCancel() {
        delegate!.eventsNearAddressFilterControllerDidCancel(self)
    }
}

class MockEditAddressSearchBarController: EditAddressSearchBarController {
    init() {
        super.init(
            nearbyEventsUseCase: MockNearbyEventsUseCase(),
            eventsNearAddressUseCase: MockEventsNearAddressUseCase(),
            zipCodeValidator: FakeZipCodeValidator(),
            searchBarStylist: MockSearchBarStylist(),
            resultQueue: FakeOperationQueue(),
            workerQueue: FakeOperationQueue(),
            theme: SearchBarFakeTheme()
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func simulateCancel() {
        delegate!.editAddressSearchBarControllerDidCancel(self)
    }
}
