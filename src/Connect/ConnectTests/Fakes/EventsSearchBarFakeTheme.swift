@testable import Connect

class EventsSearchBarFakeTheme: FakeTheme {
    override func eventsSearchBarBackgroundColor() -> UIColor { return UIColor.greenColor() }
    override func eventsSearchBarFont() -> UIFont { return UIFont.boldSystemFontOfSize(4444) }
    override func defaultButtonDisabledTextColor() -> UIColor { return UIColor(rgba: "#abcdef") }
    override func navigationBarButtonTextColor()  -> UIColor { return UIColor(rgba: "#111111") }
    override func eventsAddressTextColor() -> UIColor { return UIColor.redColor() }
    override func eventsAddressBackgroundColor() -> UIColor { return UIColor.brownColor() }
    override func eventsAddressBorderColor() -> UIColor { return UIColor.orangeColor() }
    override func eventsAddressCornerRadius() -> CGFloat { return 100.0 }
    override func eventsAddressBorderWidth() -> CGFloat { return 200.0 }
    override func eventsAddressPlaceholderTextColor() -> UIColor { return UIColor(rgba: "#222222") } // not explicitly tested
}
