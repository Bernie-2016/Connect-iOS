@testable import berniesanders
import Quick
import Nimble
import KSDeferred
import CoreLocation
import MapKit

class EventRepositoryFakeURLProvider: FakeURLProvider {
    let returnedURL = NSURL(string: "https://example.com/berneseeventsss/")!

    override func eventsURL() -> NSURL! {
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
    var subject: ConcreteEventRepository!
    let jsonClient = FakeJSONClient()
    let urlProvider = EventRepositoryFakeURLProvider()
    let eventDeserializer = FakeEventDeserializer()
    let operationQueue = FakeOperationQueue()
    let geocoder = FakeGeocoder()
    var receivedEvents: Array<Event>!
    var receivedError: NSError!

    override func spec() {
        describe("ConcreteEventRepository") {
            self.subject = ConcreteEventRepository(
                geocoder: self.geocoder,
                urlProvider: self.urlProvider,
                jsonClient: self.jsonClient,
                eventDeserializer: self.eventDeserializer,
                operationQueue: self.operationQueue
            )

            describe(".fetchEventsWithZipCode") {
                beforeEach {
                    self.subject.fetchEventsWithZipCode("90210", radiusMiles: 50.1, completion: { (events) -> Void in
                        self.receivedEvents = events
                        }, error: { (error) -> Void in
                            self.receivedError = error
                    })
                }

                it("tries to geocode the zip code") {
                    expect(self.geocoder.lastReceivedAddressString).to(equal("90210"))
                }

                context("when geocoding succeeds") {
                    beforeEach {
                        let coordinate = CLLocationCoordinate2DMake(12.34, 23.45)
                        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)

                        let otherCoordinate = CLLocationCoordinate2DMake(11.11, 11.11)
                        let otherPlacemark = MKPlacemark(coordinate: otherCoordinate, addressDictionary: nil)
                        self.geocoder.lastReceivedCompletionHandler([placemark, otherPlacemark], nil)
                    }

                    it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                        expect(self.jsonClient.deferredsByURL.count).to(equal(1))
                        expect(self.jsonClient.deferredsByURL.keys.first).to(equal(NSURL(string: "https://example.com/berneseeventsss/")))
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

                        expect(self.jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                        expect(self.jsonClient.lastMethod).to(equal("POST"))
                    }

                    context("when the request to the JSON client succeeds") {
                        let expectedJSONDictionary = NSDictionary()
                        let expectedEvents = self.eventDeserializer.returnedEvents

                        beforeEach {
                            let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.returnedURL]!

                            deferred.resolveWithValue(expectedJSONDictionary)
                        }

                        it("passes the JSON document to the events deserializer") {
                            expect(self.eventDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                        }

                        it("calls the completion handler with the deserialized value objects on the operation queue") {
                            self.operationQueue.lastReceivedBlock()
                            expect(self.receivedEvents.count).to(equal(1))
                            expect(self.receivedEvents.first!).to(beIdenticalTo(expectedEvents.first!))
                        }
                    }

                    context("when he request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                        beforeEach {
                            let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.returnedURL]!

                            deferred.resolveWithValue([1,2,3])
                        }

                        it("calls the completion handler with an error") {
                            self.operationQueue.lastReceivedBlock()
                            expect(self.receivedError).notTo(beNil())
                        }
                    }

                    context("when the request to the JSON client fails") {
                        it("forwards the error to the caller on the operation queue") {
                            let deferred: KSDeferred = self.jsonClient.deferredsByURL[self.urlProvider.returnedURL]!
                            let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                            deferred.rejectWithError(expectedError)

                            self.operationQueue.lastReceivedBlock()
                            expect(self.receivedError).to(beIdenticalTo(expectedError))
                        }
                    }
                }

                context("when geocoding fails") {
                    let expectedError = NSError(domain: "some domain", code: 0, userInfo: nil)

                    beforeEach {
                        self.geocoder.lastReceivedCompletionHandler(nil, expectedError)
                    }

                    it("calls the error handler with the geocoding error") {
                        expect(self.receivedError).to(beIdenticalTo(expectedError))
                    }
                }
            }
        }
    }
}
