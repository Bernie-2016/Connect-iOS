@testable import Movement
import Quick
import Nimble
import CoreLocation
import MapKit

class EventRepositoryFakeURLProvider: FakeURLProvider {
    let returnedURL = NSURL(string: "https://example.com/berneseeventsss/")!

    override func eventsURL() -> NSURL {
        return returnedURL
    }
}

class FakeEventDeserializer: EventDeserializer {
    var lastReceivedJSONDictionary: NSDictionary!
    let returnedEvents = [TestUtils.eventWithName("Some event")]

    func deserializeEvents(jsonDictionary: NSDictionary) -> Array<Event> {
        lastReceivedJSONDictionary = jsonDictionary
        return returnedEvents
    }
}

class FakeGeocoder : CLGeocoder {
    var lastReceivedAddressString : String!
    var lastReceivedCompletionHandler : CLGeocodeCompletionHandler!
    override func geocodeAddressString(addressString: String, completionHandler: CLGeocodeCompletionHandler) {
        self.lastReceivedAddressString = addressString
        self.lastReceivedCompletionHandler = completionHandler
    }
}

class ConcreteEventRepositorySpec : QuickSpec {
    override func spec() {
        describe("ConcreteEventRepository") {
            var subject: ConcreteEventRepository!
            var geocoder: FakeGeocoder!
            let urlProvider = EventRepositoryFakeURLProvider()
            var jsonClient: FakeJSONClient!
            var eventDeserializer: FakeEventDeserializer!
            var operationQueue: FakeOperationQueue!

            var receivedEventSearchResult: EventSearchResult!
            var receivedError: NSError!

            beforeEach {
                geocoder = FakeGeocoder()
                jsonClient = FakeJSONClient()
                eventDeserializer = FakeEventDeserializer()
                operationQueue = FakeOperationQueue()

                subject = ConcreteEventRepository(
                    geocoder: geocoder,
                    urlProvider: urlProvider,
                    jsonClient: jsonClient,
                    eventDeserializer: eventDeserializer,
                    operationQueue: operationQueue
                )
            }

            describe(".fetchEventsWithZipCode") {
                beforeEach {
                    receivedEventSearchResult = nil
                    receivedError = nil

                    subject.fetchEventsWithZipCode("90210", radiusMiles: 50.1, completion: { (eventSearchResult) -> Void in
                        receivedEventSearchResult = eventSearchResult
                        }, error: { (error) -> Void in
                            receivedError = error
                    })
                }

                it("tries to geocode the zip code") {
                    expect(geocoder.lastReceivedAddressString).to(equal("90210"))
                }

                context("when geocoding succeeds") {
                    var expectedLocation: CLLocation!

                    beforeEach {
                        let coordinate = CLLocationCoordinate2DMake(12.34, 23.45)
                        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                        expectedLocation = placemark.location

                        let otherCoordinate = CLLocationCoordinate2DMake(11.11, 11.11)
                        let otherPlacemark = MKPlacemark(coordinate: otherCoordinate, addressDictionary: nil)

                        geocoder.lastReceivedCompletionHandler([placemark, otherPlacemark], nil)
                    }

                    it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                        expect(jsonClient.promisesByURL.count).to(equal(1))
                        expect(jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://example.com/berneseeventsss/")))
                        let expectedFilterConditions = [
                            [
                                "range": [
                                    "event_date": [
                                        "lte": "now+6M/d",
                                        "gte": "now"
                                    ]
                                ]
                            ],
                            [
                                "geo_distance": [
                                    "distance": "50.1mi",
                                    "location": [
                                        "lat": 12.34,
                                        "lon": 23.45
                                    ]
                                ]
                            ]
                        ]

                        let expectedSortCriteria = [
                            [
                                "event_date" : [
                                    "order" : "asc"
                                ]
                            ],
                            [
                                "_geo_distance": [
                                    "location": [
                                        "lat":  12.34,
                                        "lon": 23.45
                                    ],
                                    "order":         "asc",
                                    "unit":          "mi",
                                    "distance_type": "plane"
                                ]
                            ]
                        ]

                        let expectedHTTPBodyDictionary =
                        [
                            "from": 0, "size": 30,
                            "_source": ["venue", "name", "timezone", "start_time", "url", "capacity", "attendee_count", "event_type_name", "description", "url"],
                            "query": [
                                "filtered": [
                                    "query": [
                                        "match_all": [

                                        ]
                                    ],
                                    "filter": [
                                        "bool": [
                                            "must": expectedFilterConditions
                                        ]
                                    ]
                                ]
                            ],
                            "sort": expectedSortCriteria
                        ]

                        expect(jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                        expect(jsonClient.lastMethod).to(equal("POST"))
                    }

                    context("when the request to the JSON client succeeds") {
                        let expectedJSONDictionary = NSDictionary()
                        var expectedEvents: Array<Event>!

                        beforeEach {
                            expectedEvents = eventDeserializer.returnedEvents
                            let promise = jsonClient.promisesByURL[urlProvider.returnedURL]!

                            promise.success(expectedJSONDictionary)
                            expect(operationQueue.lastReceivedBlock).toEventuallyNot(beNil())
                        }

                        it("passes the JSON document to the events deserializer") {expect(eventDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                        }

                        it("calls the completion handler with an event search object containing the deserialized value objects on the operation queue") {
                            operationQueue.lastReceivedBlock()

                            expect(receivedEventSearchResult.searchCentroid).to(equal(expectedLocation))
                            expect(receivedEventSearchResult.events.count).to(equal(1))
                            expect(receivedEventSearchResult.events.first!).to(beIdenticalTo(expectedEvents.first!))
                        }
                    }

                    context("when he request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                        beforeEach {
                            expect(receivedEventSearchResult).to(beNil())

                            let promise = jsonClient.promisesByURL[urlProvider.returnedURL]!

                            promise.success([1,2,3])
                            expect(operationQueue.lastReceivedBlock).toEventuallyNot(beNil())
                        }

                        it("calls the completion handler with an error") {
                            expect(receivedEventSearchResult).to(beNil())
                            expect(operationQueue.lastReceivedBlock).toEventuallyNot(beNil())
                            operationQueue.lastReceivedBlock()
                            expect(receivedEventSearchResult).toEventually(beNil())
                            expect(receivedError).toEventuallyNot(beNil())
                        }
                    }

                    context("when the request to the JSON client fails") {
                        it("forwards the error to the caller on the operation queue") {
                            let promise = jsonClient.promisesByURL[urlProvider.returnedURL]!
                            let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                            promise.failure(expectedError)
                            expect(operationQueue.lastReceivedBlock).toEventuallyNot(beNil())

                            operationQueue.lastReceivedBlock()
                            expect(receivedError).to(equal(expectedError))
                        }
                    }
                }

                context("when geocoding fails") {
                    let expectedError = NSError(domain: "some domain", code: 0, userInfo: nil)

                    beforeEach {
                        geocoder.lastReceivedCompletionHandler(nil, expectedError)
                    }

                    it("calls the error handler with the geocoding error") {
                        expect(receivedError).to(beIdenticalTo(expectedError))
                    }
                }
            }
        }
    }
}
