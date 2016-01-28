import Foundation
import CBGPromise

enum ActionAlertRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(JSONClientError)
}

extension ActionAlertRepositoryError: Equatable {}

func == (lhs: ActionAlertRepositoryError, rhs: ActionAlertRepositoryError) -> Bool {
    switch (lhs, rhs) {
        case (.InvalidJSON, .InvalidJSON):
            return true // punt on this for now.
        case (.ErrorInJSONClient(let lhsJSONClientError), .ErrorInJSONClient(let rhsJSONClientError)):
            return lhsJSONClientError == rhsJSONClientError
        default:
            return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

typealias ActionAlertsFuture = Future<[ActionAlert], ActionAlertRepositoryError>
typealias ActionAlertsPromise = Promise<[ActionAlert], ActionAlertRepositoryError>

protocol ActionAlertRepository {
    func fetchActionAlerts() -> ActionAlertsFuture
}

class StockActionAlertRepository: ActionAlertRepository {
    private let jsonClient: JSONClient
    private let actionAlertDeserializer: ActionAlertDeserializer!
    private let urlProvider: URLProvider

    init(jsonClient: JSONClient, actionAlertDeserializer: ActionAlertDeserializer, urlProvider: URLProvider) {
        self.jsonClient = jsonClient
        self.actionAlertDeserializer = actionAlertDeserializer
        self.urlProvider = urlProvider
    }

    func fetchActionAlerts() -> ActionAlertsFuture {
        let promise = ActionAlertsPromise()

        let jsonFuture = jsonClient.JSONPromiseWithURL(urlProvider.actionAlertsURL(), method: "GET", bodyDictionary: nil)

        jsonFuture.then { deserializedObject in
            guard let jsonDictionary = deserializedObject as? Dictionary<String, AnyObject> else {
                promise.reject(.InvalidJSON(jsonObject: deserializedObject))
                return
            }

            let actionAlerts = self.actionAlertDeserializer.deserializeActionAlerts(jsonDictionary)
            promise.resolve(actionAlerts)
        }

        jsonFuture.error { receivedError in
            promise.reject(.ErrorInJSONClient(receivedError))
        }

        return promise.future
    }
}
