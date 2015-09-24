import Foundation
import CoreLocation

public class ConcreteEventRepository : EventRepository {
    let geocoder: CLGeocoder!
    let urlProvider: URLProvider!
    let jsonClient: JSONClient!
    let eventDeserializer: EventDeserializer!
    let operationQueue: NSOperationQueue!
    
    public init(
        geocoder: CLGeocoder,
        urlProvider: URLProvider,
        jsonClient: JSONClient,
        eventDeserializer: EventDeserializer,
        operationQueue: NSOperationQueue) {
            self.geocoder = geocoder
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.eventDeserializer = eventDeserializer
            self.operationQueue = operationQueue
    }

    
    public func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float, completion: (Array<Event>) -> Void, error: (NSError) -> Void) {
        self.geocoder.geocodeAddressString(zipCode, completionHandler: { (placemarks, geocodingError) -> Void in
            if(geocodingError != nil) {
                error(geocodingError)
                return
            }
            
            let placemark = placemarks.first as! CLPlacemark
            let location = placemark.location!

            let url = self.urlProvider.eventsURL()

            let HTTPBodyDictionary = [
                "query": [
                    "filtered": [
                        "query": [
                            "match_all": [
                                
                            ]
                        ],
                        "filter": [
                            "geo_distance": [
                                "distance": "\(radiusMiles)mi",
                                "location": [
                                    "lat": location.coordinate.latitude,
                                    "lon": location.coordinate.longitude
                                ]
                            ]
                        ]
                    ]
                ]
            ]
            
            let eventsPromise = self.jsonClient.JSONPromiseWithURL(url, method: "POST", bodyDictionary: HTTPBodyDictionary)
            
            eventsPromise.then({ (jsonDictionary) -> AnyObject! in
                var parsedEvents = self.eventDeserializer.deserializeEvents(jsonDictionary as! NSDictionary)
                
                self.operationQueue.addOperationWithBlock({ () -> Void in
                    completion(parsedEvents)
                })
                
                return parsedEvents
                }, error: { (receivedError) -> AnyObject! in
                    self.operationQueue.addOperationWithBlock({ () -> Void in
                        error(receivedError)
                    })
                    return receivedError
            })
        })
    }
}