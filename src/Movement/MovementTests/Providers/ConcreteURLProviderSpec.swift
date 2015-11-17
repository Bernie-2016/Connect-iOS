import Foundation
import Quick
import Nimble
@testable import Movement
import CoreLocation

class ConcreteURLProviderSpec : QuickSpec {
    var subject : ConcreteURLProvider!

    override func spec() {
        describe("ConcreteURLProvider") {
            beforeEach {
                self.subject = ConcreteURLProvider()
            }

            describe("building a maps URL for an event") {
                var event: Event!

                context("with an event with a street address") {
                    beforeEach {
                        let location = CLLocation(latitude: 0, longitude: 0)
                        event = Event(name: "name", startDate: NSDate(), timeZone: NSTimeZone(abbreviation: "PST")!, attendeeCapacity: 2, attendeeCount: 2, streetAddress: "1 Big Avenue", city: "Petaluma", state: "CA", zip: "11111", location: location, description: "desc", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")
                    }

                    it("builds the correct URL") {
                        expect(self.subject.mapsURLForEvent(event)).to(equal(NSURL(string: "https://maps.apple.com/?address=1%20Big%20Avenue,Petaluma,CA,11111")))
                    }
                }

                context("with an event that lacks a street address") {
                    beforeEach {
                        let location = CLLocation(latitude: 0, longitude: 0)
                        event = Event(name: "name", startDate: NSDate(), timeZone: NSTimeZone(abbreviation: "PST")!, attendeeCapacity: 2, attendeeCount: 2, streetAddress: nil, city: "Santa Rosa", state: "WA", zip: "22222", location: location, description: "desc", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")
                    }

                    it("builds the correct URL") {
                        expect(self.subject.mapsURLForEvent(event)).to(equal(NSURL(string: "https://maps.apple.com/?address=Santa%20Rosa,WA,22222")))
                    }
                }
            }

            describe("building the feedback form URL") {
                var urlComponents: NSURLComponents!
                beforeEach {
                    let url = self.subject.feedbackFormURL()
                    urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
                }

                it("includes the platform") {
                    let platformQueryItem = urlComponents.queryItems!.first!
                    expect(platformQueryItem.name).to(equal("entry.506"))
                    expect(platformQueryItem.value).to(equal("iOS"))
                }

                it("includes the marketing and internal version numbers") {
                    let marketingVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
                    let internalBuildNumber  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String

                    let expectedVersionString = "\(marketingVersion) (\(internalBuildNumber))"
                    let platformQueryItem = urlComponents.queryItems!.last!

                    expect(platformQueryItem.name).to(equal("entry.937851719"))
                    expect(platformQueryItem.value).to(equal(expectedVersionString))
                }
            }
        }
    }
}
