import Foundation

public class NSJSONSerializationProvider {
    public init() {}

    public func jsonObjectWithData(data: NSData, options opt: NSJSONReadingOptions) throws -> AnyObject {
        return try NSJSONSerialization.JSONObjectWithData(data, options: opt)
    }

    public func dataWithJSONObject(obj: AnyObject, options opt: NSJSONWritingOptions) throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(obj, options: opt)
    }
}
