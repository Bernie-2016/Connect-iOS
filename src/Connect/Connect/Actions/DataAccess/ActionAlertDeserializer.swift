import Foundation

enum ActionAlertDeserializerError: ErrorType {
    case InvalidJSON(Dictionary<String, AnyObject>)
    case MissingAttribute(String)
}

extension ActionAlertDeserializerError: Equatable {}

func == (lhs: ActionAlertDeserializerError, rhs: ActionAlertDeserializerError) -> Bool {
    switch (lhs, rhs) {
    case (.InvalidJSON, .InvalidJSON):
        return true // punt on this for now
    case (.MissingAttribute(let lhsAttribute), .MissingAttribute(let rhsAttribute)):
        return lhsAttribute == rhsAttribute
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

protocol ActionAlertDeserializer {
    func deserializeActionAlerts(jsonDictionary: Dictionary<String, AnyObject>) -> [ActionAlert]
    func deserializeActionAlert(jsonDictionary: Dictionary<String, AnyObject>) throws -> ActionAlert
}

class StockActionAlertDeserializer: ActionAlertDeserializer {
    func deserializeActionAlerts(jsonDictionary: Dictionary<String, AnyObject>) -> [ActionAlert] {
        var actionAlerts = [ActionAlert]()

        guard let actionAlertDictionaries = jsonDictionary["data"] as? Array<Dictionary<String, AnyObject>> else { return actionAlerts }

        for actionAlertDictionary in actionAlertDictionaries {
            do {
                let actionAlert = try deserializeActionAlert(["data": actionAlertDictionary])
                actionAlerts.append(actionAlert)
            } catch {
                continue
            }
        }

        return actionAlerts

    }

    func deserializeActionAlert(jsonDictionary: Dictionary<String, AnyObject>) throws -> ActionAlert {
        guard let actionAlertDictionary = jsonDictionary["data"] else {
            throw ActionAlertDeserializerError.MissingAttribute("data")
        }
        guard let attributesDictionary = actionAlertDictionary["attributes"] as? Dictionary<String, AnyObject> else { throw ActionAlertDeserializerError.MissingAttribute("attributes") }
        guard let id = actionAlertDictionary["id"] as? String else { throw ActionAlertDeserializerError.MissingAttribute("id") }
        guard let title = attributesDictionary["title"] as? String else { throw ActionAlertDeserializerError.MissingAttribute("title") }
        guard let body = attributesDictionary["body"] as? String else { throw ActionAlertDeserializerError.MissingAttribute("body") }
        guard let date = attributesDictionary["date"] as? String else { throw ActionAlertDeserializerError.MissingAttribute("date") }

        let targetURL = extractURLWithAttributeName("target_url", attributesDictionary: attributesDictionary)
        let twitterURL = extractURLWithAttributeName("twitter_url", attributesDictionary: attributesDictionary)
        var tweetID = attributesDictionary["tweet_id"] as? String
        tweetID = tweetID?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ? tweetID : nil

        let actionAlert = ActionAlert(identifier: id, title: title, body: body, date: date, targetURL: targetURL, twitterURL: twitterURL, tweetID: tweetID)

        return actionAlert
    }

    // MARK: Private

    private func extractURLWithAttributeName(attributeName: String, attributesDictionary: Dictionary<String, AnyObject>) -> NSURL? {
        let targetURLString = attributesDictionary[attributeName] as? String
        var targetURL: NSURL?

        if targetURLString != nil && targetURLString?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            targetURL = NSURL(string: targetURLString!)
        }

        return targetURL
    }
}
