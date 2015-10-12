import Foundation

class FakeDateFormatter : NSDateFormatter {
    var lastReceivedDate : NSDate!
    var lastConfiguredTimeZone : NSTimeZone!

    override func stringFromDate(date: NSDate) -> String {
        self.lastReceivedDate = date
        return "THIS IS THE DATE!"
    }
}
