import Quick
import Nimble

@testable import Connect

class EventsErrorControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsErrorController") {
            var subject: EventsErrorController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var resultQueue: FakeOperationQueue!
            let theme = EventsErrorTheme()

            beforeEach {
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                resultQueue = FakeOperationQueue()

                subject = EventsErrorController(
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    resultQueue: resultQueue,
                    theme: theme
                )
            }

            describe("when the view loads") {
                it("sets up the sub views correctly") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.genericErrorView))
                    expect(subject.view.subviews).to(contain(subject.permissionsErrorView))

                    expect(subject.genericErrorView.subviews).to(contain(subject.genericErrorHeadingLabel))
                    expect(subject.genericErrorView.subviews).to(contain(subject.genericErrorDetailLabel))

                    expect(subject.permissionsErrorView.subviews).to(contain(subject.permissionsErrorImageView))
                    expect(subject.permissionsErrorView.subviews).to(contain(subject.permissionsErrorHeadingLabel))
                }

                it("sets the image in the image view correctly") {subject.view.layoutSubviews()
                    subject.view.layoutSubviews()

                    expect(subject.permissionsErrorImageView.image) == UIImage(named: "eventSearch")
                }

                it("sets the correct text for the labels") {
                    subject.view.layoutSubviews()

                    expect(subject.permissionsErrorHeadingLabel.text) == "Tap the search box to begin"
                    expect(subject.genericErrorHeadingLabel.text) == "Something went wrong"
                    expect(subject.genericErrorDetailLabel.text) == "Please try your search again"
                }

                it("styles the view with the theme") {
                    subject.view.layoutSubviews()

                    expect(subject.permissionsErrorHeadingLabel.font) == UIFont.systemFontOfSize(42)
                    expect(subject.genericErrorHeadingLabel.font) == UIFont.systemFontOfSize(42)
                    expect(subject.genericErrorDetailLabel.font) == UIFont.systemFontOfSize(43)

                    expect(subject.permissionsErrorHeadingLabel.textColor) == UIColor.magentaColor()
                    expect(subject.genericErrorHeadingLabel.textColor) == UIColor.magentaColor()
                    expect(subject.genericErrorDetailLabel.textColor) == UIColor.magentaColor()
                }
            }

            describe("as a nearby events use case observer") {
                describe("when the use case fails with a permissions error") {
                    it("hides the generic error view") {
                        subject.genericErrorView.hidden = false

                        let error = NearbyEventsUseCaseError.FindingLocationError(.PermissionsError)
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)
                        resultQueue.lastReceivedBlock()

                        expect(subject.genericErrorView.hidden) == true
                    }

                    it("shows the permissions error view") {
                        subject.permissionsErrorView.hidden = true

                        let error = NearbyEventsUseCaseError.FindingLocationError(.PermissionsError)
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)
                        resultQueue.lastReceivedBlock()

                        expect(subject.permissionsErrorView.hidden) == false
                    }
                }

                describe("when the use case fails with any other error") {
                    it("shows the generic error view") {
                        subject.genericErrorView.hidden = true

                        let clError = NSError(domain: "", code: 42, userInfo: nil)
                        let error = NearbyEventsUseCaseError.FindingLocationError(.CoreLocationError(clError))
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)
                        resultQueue.lastReceivedBlock()

                        expect(subject.genericErrorView.hidden) == false
                    }

                    it("hides the permissions error view") {
                        subject.permissionsErrorView.hidden = false

                        let clError = NSError(domain: "", code: 42, userInfo: nil)
                        let error = NearbyEventsUseCaseError.FindingLocationError(.CoreLocationError(clError))
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)
                        resultQueue.lastReceivedBlock()

                        expect(subject.permissionsErrorView.hidden) == true
                    }
                }
            }

            describe("as an events near address use case observer") {
                describe("when the use case fails with an error") {
                    it("shows the generic error view") {
                        subject.genericErrorView.hidden = true

                        let geoError = NSError(domain: "", code: 52, userInfo: nil)
                        eventsNearAddressUseCase.simulateFailingToFindEvents(.GeocodingError(geoError))
                        resultQueue.lastReceivedBlock()

                        expect(subject.genericErrorView.hidden) == false
                    }

                    it("hides the permissions error view") {
                        subject.permissionsErrorView.hidden = false

                        let geoError = NSError(domain: "", code: 52, userInfo: nil)
                        eventsNearAddressUseCase.simulateFailingToFindEvents(.GeocodingError(geoError))
                        resultQueue.lastReceivedBlock()

                        expect(subject.permissionsErrorView.hidden) == true
                    }
                }
            }
        }
    }
}

private class EventsErrorTheme: FakeTheme {
    override func eventsErrorTextColor() -> UIColor { return UIColor.magentaColor() }
    override func eventsErrorHeadingFont() -> UIFont { return UIFont.systemFontOfSize(42) }
    override func eventsErrorDetailFont() -> UIFont { return UIFont.systemFontOfSize(43) }
}
