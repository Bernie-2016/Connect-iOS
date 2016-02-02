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
            guard let id = actionAlertDictionary["id"] as? String else { continue }
            guard let title = attributesDictionary["title"] as? String else { continue }
            guard let body = attributesDictionary["body"] as? String else { continue }
            guard let date = attributesDictionary["date"] as? String else { continue }

            let targetURL = extractURLWithAttributeName("target_url", attributesDictionary: attributesDictionary)
            let twitterURL = extractURLWithAttributeName("twitter_url", attributesDictionary: attributesDictionary)
            var tweetID = attributesDictionary["tweet_id"] as? String
            tweetID = tweetID?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ? tweetID : nil

            let actionAlert = ActionAlert(identifier: id, title: title, body: body, date: date, targetURL: targetURL, twitterURL: twitterURL, tweetID: tweetID)
            actionAlerts.append(actionAlert)
        }

        return actionAlerts

    }

    private func extractURLWithAttributeName(attributeName: String, attributesDictionary: Dictionary<String, AnyObject>) -> NSURL? {
        let targetURLString = attributesDictionary[attributeName] as? String
        var targetURL: NSURL?

        if targetURLString != nil && targetURLString?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            targetURL = NSURL(string: targetURLString!)
        }

        return targetURL
    }
}
