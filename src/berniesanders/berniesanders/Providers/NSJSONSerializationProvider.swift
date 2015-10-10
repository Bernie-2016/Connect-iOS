import Foundation

public class NSJSONSerializationProvider {
    public init() {}

    public func jsonObjectWithData(data: NSData, options opt: NSJSONReadingOptions, error: NSErrorPointer) -> AnyObject? {
        return NSJSONSerialization.JSONObjectWithData(data, options: opt, error: error)
    }

    public func dataWithJSONObject(obj: AnyObject, options opt: NSJSONWritingOptions, error: NSErrorPointer) -> NSData? {
        return NSJSONSerialization.dataWithJSONObject(obj, options: opt, error: error)
    }
}
