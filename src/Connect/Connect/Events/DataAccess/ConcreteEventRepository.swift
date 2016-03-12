import Foundation
import CoreLocation

class ConcreteEventRepository: EventRepository {
    private let geocoder: CLGeocoder
    private let urlProvider: URLProvider
    private let jsonClient: JSONClient
    private let eventDeserializer: EventDeserializer

    init(geocoder: CLGeocoder,
         urlProvider: URLProvider,
         jsonClient: JSONClient,
         eventDeserializer: EventDeserializer) {
            self.geocoder = geocoder
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.eventDeserializer = eventDeserializer
    }

    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture {
        let promise = EventSearchResultPromise()

        self.geocoder.geocodeAddressString(zipCode, completionHandler: { (placemarks, geocodingError) -> Void in
            if geocodingError != nil {
                let wrappedError = EventRepositoryError.GeocodingError(error: geocodingError!)
                promise.reject(wrappedError)
                return
            }

            let placemark = placemarks!.first!
            let location = placemark.location!

            let url = self.urlProvider.eventsURL()

            let HTTPBodyDictionary = self.HTTPBodyDictionaryWithLatitude(
                location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radiusMiles: radiusMiles)

            let eventsJSONFuture = self.jsonClient.JSONPromiseWithURL(url, method: "POST", bodyDictionary: HTTPBodyDictionary)

            eventsJSONFuture.then { deserializedObject in
                guard let jsonDictionary = deserializedObject as? NSDictionary else {
                    let invalidJSONError = EventRepositoryError.InvalidJSONError(jsonObject: deserializedObject)
                    promise.reject(invalidJSONError)
                    return
                }

                let parsedEvents = self.eventDeserializer.deserializeEvents(jsonDictionary)
                let eventSearchResult = EventSearchResult(searchCentroid: location, events: parsedEvents)
                promise.resolve(eventSearchResult)
            }

            eventsJSONFuture.error { receivedError in
                let jsonClientError = EventRepositoryError.ErrorInJSONClient(error: receivedError)
                promise.reject(jsonClientError)
            }
        })

        return promise.future
    }

    func fetchEventsAroundLocation(location: CLLocation, radiusMiles: Float) -> EventSearchResultFuture {
        let promise = EventSearchResultPromise()

        return promise.future
    }

    // MARK: Private

    func HTTPBodyDictionaryWithLatitude(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radiusMiles: Float) -> NSDictionary {
        return [
            "sort": [

                [
                "event_date" : [
                    "order" : "asc"
                ]],

                ["_geo_distance": [
                    "location": [
                        "lat":  latitude,
                        "lon": longitude
                    ],
                    "order":         "asc",
                    "unit":          "mi",
                    "distance_type": "plane"
                ]
                    ]
            ],

            "from": 0, "size": 30,
            "_source": ["venue", "name", "timezone", "start_time", "url", "capacity", "attendee_count", "event_type_name", "description", "url"],
            "query": [
                "filtered": [
                    "query": [
                        "match_all": []
                    ],
                    "filter": [
                        "bool": [
                            "must": self.filterConditions(latitude, longitude: longitude, radiusMiles: radiusMiles)
                        ]
                    ]
                ]
            ]

        ]
    }

    func filterConditions(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radiusMiles: Float) -> Array<AnyObject> {
        return [
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
                    "distance": "\(radiusMiles)mi",
                    "location": [
                        "lat": latitude,
                        "lon": longitude
                    ]
                ]
            ]
        ]
    }
}
