@testable import Connect

class EventsSearchBarFakeTheme: FakeTheme {
    override func eventsSearchBarBackgroundColor() -> UIColor { return UIColor.greenColor() }
    override func eventsSearchBarFont() -> UIFont { return UIFont.boldSystemFontOfSize(4444) }
    override func defaultButtonDisabledTextColor() -> UIColor { return UIColor(rgba: "#abcdef") }
    override func navigationBarButtonTextColor()  -> UIColor { return UIColor(rgba: "#111111") }
    override func eventsZipCodeTextColor() -> UIColor { return UIColor.redColor() }
    override func eventsZipCodeBackgroundColor() -> UIColor { return UIColor.brownColor() }
    override func eventsZipCodeBorderColor() -> UIColor { return UIColor.orangeColor() }
    override func eventsZipCodeCornerRadius() -> CGFloat { return 100.0 }
    override func eventsZipCodeBorderWidth() -> CGFloat { return 200.0 }
    override func eventsZipCodePlaceholderTextColor() -> UIColor { return UIColor(rgba: "#222222") } // not explicitly tested
}
