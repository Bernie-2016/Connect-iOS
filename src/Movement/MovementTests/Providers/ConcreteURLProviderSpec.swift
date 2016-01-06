import Foundation
import Quick
import Nimble
@testable import Movement
import CoreLocation

class ConcreteURLProviderSpec : QuickSpec {
    override func spec() {
        var subject : ConcreteURLProvider!

        describe("ConcreteURLProvider") {
            beforeEach {
                subject = ConcreteURLProvider()
            }

            describe("building a maps URL for an event") {
                var event: Event!

                context("with an event with a street address") {
                    beforeEach {
                        let location = CLLocation(latitude: 0, longitude: 0)
                        event = Event(name: "name", startDate: NSDate(), timeZone: NSTimeZone(abbreviation: "PST")!, attendeeCapacity: 2, attendeeCount: 2, streetAddress: "1 Big Avenue", city: "Petaluma", state: "CA", zip: "11111", location: location, description: "desc", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")
                    }

                    it("builds the correct URL") {
                        expect(subject.mapsURLForEvent(event)).to(equal(NSURL(string: "https://maps.apple.com/?address=1%20Big%20Avenue,Petaluma,CA,11111")))
                    }
                }

                context("with an event that lacks a street address") {
                    beforeEach {
                        let location = CLLocation(latitude: 0, longitude: 0)
                        event = Event(name: "name", startDate: NSDate(), timeZone: NSTimeZone(abbreviation: "PST")!, attendeeCapacity: 2, attendeeCount: 2, streetAddress: nil, city: "Santa Rosa", state: "WA", zip: "22222", location: location, description: "desc", url: NSURL(string: "https://example.com")!, eventTypeName: "Big Time Bernie Fun")
                    }

                    it("builds the correct URL") {
                        expect(subject.mapsURLForEvent(event)).to(equal(NSURL(string: "https://maps.apple.com/?address=Santa%20Rosa,WA,22222")))
                    }
                }
            }

            describe("building the feedback form URL") {
                var urlComponents: NSURLComponents!
                beforeEach {
                    let url = subject.feedbackFormURL()
                    urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
                }

                it("includes the marketing and internal version numbers") {
                    let marketingVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
                    let internalBuildNumber  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String

                    let expectedVersionString = "\(marketingVersion) (\(internalBuildNumber))"
                    let platformQueryItem = urlComponents.queryItems!.last!

                    expect(platformQueryItem.name).to(equal("entry.1652819874"))
                    expect(platformQueryItem.value).to(equal(expectedVersionString))
                }
            }

            describe("building the YouTube thumbnail URL") {
                it("returns the correct URL") {
                    expect(subject.youtubeVideoURL("some-id")).to(equal(NSURL(string: "https://www.youtube.com/watch?v=some-id")))
                }
            }

            describe("building the YouTube thumbnail URL") {
                it("returns the correct URL") {
                    expect(subject.youtubeThumbnailURL("some-id")).to(equal(NSURL(string: "https://img.youtube.com/vi/some-id/maxresdefault.jpg")))
                }
            }
        }
    }
}
