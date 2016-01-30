import Foundation

protocol ActionAlertDeserializer {
    func deserializeActionAlerts(jsonDictionary: Dictionary<String, AnyObject>) -> [ActionAlert]
}

class StockActionAlertDeserializer: ActionAlertDeserializer {
    func deserializeActionAlerts(jsonDictionary: Dictionary<String, AnyObject>) -> [ActionAlert] {
        var actionAlerts = [ActionAlert]()

        guard let actionAlertDictionaries = jsonDictionary["data"] as? Array<Dictionary<String, AnyObject>> else { return actionAlerts }

        for actionAlertDictionary in actionAlertDictionaries {
            guard let attributesDictionary = actionAlertDictionary["attributes"] as? Dictionary<String, AnyObject> else { continue }
            guard let title = attributesDictionary["title"] as? String else { continue }
            guard let body = attributesDictionary["body"] as? String else { continue }
            guard let date = attributesDictionary["date"] as? String else { continue }

            let actionAlert = ActionAlert(title: title, body: body, date: date)
            actionAlerts.append(actionAlert)
        }

        return actionAlerts

    }
}
