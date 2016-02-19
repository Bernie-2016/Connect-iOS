# CBGPromise

[![CI Status](https://img.shields.io/circleci/project/cbguder/CBGPromise/master.svg)](https://circleci.com/gh/cbguder/CBGPromise/tree/master)
[![Version](https://img.shields.io/cocoapods/v/CBGPromise.svg?style=flat)](http://cocoapods.org/pods/CBGPromise)
[![License](https://img.shields.io/cocoapods/l/CBGPromise.svg?style=flat)](http://cocoapods.org/pods/CBGPromise)
[![Platform](https://img.shields.io/cocoapods/p/CBGPromise.svg?style=flat)](http://cocoapods.org/pods/CBGPromise)

## Installation

CBGPromise is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "CBGPromise"
```

## Usage

```swift
import CBGPromise

class Test {
    func getToken() -> Future<String, NSError> {
        let promise = Promise<String, NSError>()

        doAsyncCall {
            promise.resolve("Test")
        }

        return promise.future
    }

    func printToken() {
        getToken().then { token in
            print(token)
        }.error { error in
            print(error)
        }
    }
}
```

## Author

Can Berk Güder

## License

CBGPromise is available under the MIT license. See the LICENSE file for more info.
