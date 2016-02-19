import Foundation

public class Future<T, ET: ErrorType> {
    var successCallbacks: [(T) -> ()]
    var errorCallbacks: [(ET) -> ()]

    public var value: T?
    public var error: ET?

    let semaphore: dispatch_semaphore_t

    init() {
        semaphore = dispatch_semaphore_create(0)
        successCallbacks = []
        errorCallbacks = []
    }

    public func then(callback: (T) -> ()) -> Future<T, ET> {
        successCallbacks.append(callback)

        if let value = value {
            callback(value)
        }
        
        return self
    }

    public func error(callback: (ET) -> ()) -> Future<T, ET> {
        errorCallbacks.append(callback)

        if let error = error {
            callback(error)
        }

        return self
    }

    public func wait() {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }

    func resolve(value: T) {
        self.value = value

        for successCallback in successCallbacks {
            successCallback(value)
        }

        dispatch_semaphore_signal(semaphore)
    }

    func reject(error: ET) {
        self.error = error

        for errorCallback in errorCallbacks {
            errorCallback(error)
        }

        dispatch_semaphore_signal(semaphore)
    }
}
