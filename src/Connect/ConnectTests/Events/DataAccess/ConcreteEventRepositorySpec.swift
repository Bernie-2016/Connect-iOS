import Quick
import Nimble
import CoreLocation
import MapKit

@testable import Connect

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

            beforeEach {
                geocoder = FakeGeocoder()
                jsonClient = FakeJSONClient()
                eventDeserializer = FakeEventDeserializer()

                subject = ConcreteEventRepository(
                    geocoder: geocoder,
                    urlProvider: urlProvider,
                    jsonClient: jsonClient,
                    eventDeserializer: eventDeserializer
                )
            }

            describe("fetching events with a given location and radius") {
                it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                    subject.fetchEventsAroundLocation(CLLocation(latitude: 12.34, longitude: 23.45), radiusMiles: 50.1)

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
                    var eventsFuture: EventSearchResultFuture!

                    beforeEach {
                        eventsFuture = subject.fetchEventsAroundLocation(CLLocation(latitude: 12.34, longitude: 23.45), radiusMiles: 50.1)

                        expectedEvents = eventDeserializer.returnedEvents
                        let promise = jsonClient.promisesByURL[urlProvider.returnedURL]!

                        promise.resolve(expectedJSONDictionary)
                    }

                    it("passes the JSON document to the events deserializer") {
                        expect(eventDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with an event search object containing the deserialized value objects on the operation queue") {
                        let receivedEventSearchResult = eventsFuture.value!
                        expect(receivedEventSearchResult.events) == expectedEvents
                    }
                }

                context("when he request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    var eventsFuture: EventSearchResultFuture!

                    beforeEach {
                        eventsFuture = subject.fetchEventsAroundLocation(CLLocation(latitude: 12.34, longitude: 23.45), radiusMiles: 50.1)
                    }

                    it("calls the completion handler with an error") {
                        let promise = jsonClient.promisesByURL[urlProvider.eventsURL()]!

                        let badObj = [1,2,3]
                        promise.resolve(badObj)

                        switch(eventsFuture.error!) {
                        case .InvalidJSONError(let jsonObject):
                            expect(jsonObject as? [Int]).to(equal(badObj))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }

                context("when the request to the JSON client fails") {
                    var eventsFuture: EventSearchResultFuture!

                    beforeEach {
                        eventsFuture = subject.fetchEventsAroundLocation(CLLocation(latitude: 12.34, longitude: 23.45), radiusMiles: 50.1)
                    }

                    it("forwards the error to the caller on the operation queue") {
                        let promise = jsonClient.promisesByURL[urlProvider.returnedURL]!
                        let underlyingError = JSONClientError.HTTPStatusCodeError(statusCode: 400, data: nil)
                        promise.reject(underlyingError)

                        switch(eventsFuture.error!) {
                        case .ErrorInJSONClient(let jsonClientError):
                            switch(jsonClientError) {
                            case .HTTPStatusCodeError(let statusCode, _):
                                expect(statusCode).to(equal(400))
                            default:
                                fail("unexpected error type")
                            }
                        default:
                            fail("unexpected error type")
                        }
                    }
                }
            }

            describe(".fetchEventsWithZipCode") {
                var eventsFuture: EventSearchResultFuture!

                beforeEach {
                    eventsFuture = subject.fetchEventsWithZipCode("90210", radiusMiles: 50.1)
                }

                it("tries to geocode the zip code") {
                    expect(geocoder.lastReceivedAddressString).to(equal("90210"))
                }

                context("when geocoding succeeds") {
                    beforeEach {
                        let coordinate = CLLocationCoordinate2DMake(12.34, 23.45)
                        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)

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

                            promise.resolve(expectedJSONDictionary)
                        }

                        it("passes the JSON document to the events deserializer") {
                            expect(eventDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                        }

                        it("calls the completion handler with an event search object containing the deserialized value objects on the operation queue") {
                            let receivedEventSearchResult = eventsFuture.value!
                            expect(receivedEventSearchResult.events) == expectedEvents
                        }
                    }

                    context("when he request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                        it("calls the completion handler with an error") {
                            let promise = jsonClient.promisesByURL[urlProvider.eventsURL()]!

                            let badObj = [1,2,3]
                            promise.resolve(badObj)

                            switch(eventsFuture.error!) {
                            case .InvalidJSONError(let jsonObject):
                                expect(jsonObject as? [Int]).to(equal(badObj))
                            default:
                                fail("unexpected error type")
                            }
                        }
                    }

                    context("when the request to the JSON client fails") {
                        it("forwards the error to the caller on the operation queue") {
                            let promise = jsonClient.promisesByURL[urlProvider.returnedURL]!
                            let underlyingError = JSONClientError.HTTPStatusCodeError(statusCode: 400, data: nil)
                            promise.reject(underlyingError)

                            switch(eventsFuture.error!) {
                            case .ErrorInJSONClient(let jsonClientError):
                                switch(jsonClientError) {
                                case .HTTPStatusCodeError(let statusCode, _):
                                    expect(statusCode).to(equal(400))
                                default:
                                    fail("unexpected error type")
                                }
                            default:
                                fail("unexpected error type")
                            }
                        }
                    }
                }

                context("when geocoding fails") {
                    let expectedError = NSError(domain: "some domain", code: 0, userInfo: nil)

                    beforeEach {
                        geocoder.lastReceivedCompletionHandler(nil, expectedError)
                    }

                    it("calls the error handler with the geocoding error") {
                        switch(eventsFuture.error!) {
                        case .GeocodingError(let error):
                            expect(error).to(beIdenticalTo(expectedError))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }
            }
        }
    }
}
