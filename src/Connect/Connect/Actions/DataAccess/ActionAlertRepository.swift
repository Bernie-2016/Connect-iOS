import Foundation
import CBGPromise

enum ActionAlertRepositoryError: ErrorType {
    case InvalidJSON(jsonObject: AnyObject)
    case DeserializerError(ActionAlertDeserializerError)
    case ErrorInJSONClient(JSONClientError)
    case NoMatchingActionAlert(ActionAlertIdentifier)
    case UnknownError(ErrorType)
}

extension ActionAlertRepositoryError: Equatable {}

func == (lhs: ActionAlertRepositoryError, rhs: ActionAlertRepositoryError) -> Bool {
    switch (lhs, rhs) {
    case (.InvalidJSON, .InvalidJSON):
        return true // punt on this for now.
    case (.ErrorInJSONClient(let lhsJSONClientError), .ErrorInJSONClient(let rhsJSONClientError)):
        return lhsJSONClientError == rhsJSONClientError
    case (.NoMatchingActionAlert(let lhsIdentifier), .NoMatchingActionAlert(let rhsIdentifier)):
        return lhsIdentifier == rhsIdentifier
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

typealias ActionAlertsFuture = Future<[ActionAlert], ActionAlertRepositoryError>
typealias ActionAlertsPromise = Promise<[ActionAlert], ActionAlertRepositoryError>
typealias ActionAlertFuture = Future<ActionAlert, ActionAlertRepositoryError>
typealias ActionAlertPromise = Promise<ActionAlert, ActionAlertRepositoryError>

protocol ActionAlertRepository {
    func fetchActionAlerts() -> ActionAlertsFuture
    func fetchActionAlert(identifier: ActionAlertIdentifier) -> ActionAlertFuture
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

        jsonFuture.then { jsonObject in
            guard let jsonDictionary = jsonObject as? Dictionary<String, AnyObject> else {
                promise.reject(.InvalidJSON(jsonObject: jsonObject))
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

    func fetchActionAlert(identifier: ActionAlertIdentifier) -> ActionAlertFuture {
        let promise = ActionAlertPromise()

        let url = urlProvider.actionAlertURL(identifier)
        let jsonFuture = jsonClient.JSONPromiseWithURL(url, method: "GET", bodyDictionary: nil)
        jsonFuture.then { jsonObject in
            guard let jsonDictionary = jsonObject as? Dictionary<String, AnyObject> else {
                promise.reject(.InvalidJSON(jsonObject: jsonObject))
                return
            }

            var actionAlert: ActionAlert!
            do {
                actionAlert = try self.actionAlertDeserializer.deserializeActionAlert(jsonDictionary)
            } catch ActionAlertDeserializerError.InvalidJSON(let invalidJSON) {
                promise.reject(.DeserializerError(.InvalidJSON(invalidJSON)))
                return
            } catch {
                promise.reject(.UnknownError(error))
            }

            promise.resolve(actionAlert)
        }

        jsonFuture.error { receivedError in
            promise.reject(.ErrorInJSONClient(receivedError))
        }

        return promise.future
    }
}
