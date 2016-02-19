import Foundation

public class Promise<T, ET: ErrorType> {
    public let future: Future<T, ET>

    public init() {
        future = Future<T, ET>()
    }

    public func resolve(value: T) {
        future.resolve(value)
    }

    public func reject(error: ET) {
        future.reject(error)
    }
}
