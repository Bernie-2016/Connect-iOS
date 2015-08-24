import Ono
import Foundation

public class ONOXMLDocumentProvider {
    public init() {
        
    }
    
    public func provideXMLDocument(data: NSData!, error: NSErrorPointer) -> ONOXMLDocument! {
        return ONOXMLDocument(data: data, error: error)
    }
}