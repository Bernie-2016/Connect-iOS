import Foundation
import UIKit

let isRunningTests = NSClassFromString("XCTestCase") != nil

if isRunningTests {
    UIApplicationMain(Process.argc, Process.unsafeArgv, nil, NSStringFromClass(SpecAppDelegate))
} else {
    UIApplicationMain(Process.argc, Process.unsafeArgv, nil, NSStringFromClass(AppDelegate))
}