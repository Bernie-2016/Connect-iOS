import Quick
import Nimble

@testable import Connect

class CMMarkdownConverterSpec: QuickSpec {
    override func spec() {
        describe("CMMarkdownConverter") {
            var subject: CMMarkdownConverter!
            beforeEach {
                subject = CMMarkdownConverter(theme: FakeCMMarkdownTheme())
            }

            describe("converting markdown to an attributed string") {
                var attributedString: NSAttributedString!

                beforeEach {
                    let markdown = "_what_ on **earth** is [that](https://www.youtube.com/watch?v=TABgNerEro8)\n# h1\n## h2\n### h3\n#### h4\n##### h5\n###### h6"

                    attributedString = subject.convertToAttributedString(markdown)
                }

                it("styles italic text using the theme") {
                    var range = NSRange(location: 0, length: 2)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: &range) as? UIFont).to(equal(UIFont.italicSystemFontOfSize(666)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 0, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }

                it("styles body text using the theme") {
                    var range = NSRange(location: 0, length: 4)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 5, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(666)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 5, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))

                    range = NSRange(location: 0, length: 2)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 15, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(666)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 15, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }

                it("styles bold text using the theme") {
                    var range = NSRange(location: 0, length: 5)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 9, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(666, weight: UIFontWeightSemibold)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 9, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }

                it("styles link text using the theme") {
                    var range = NSRange(location: 0, length: 4)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 18, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(666)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 18, effectiveRange: &range) as? UIColor).to(equal(UIColor.purpleColor()))
                    expect(attributedString.attribute(NSUnderlineStyleAttributeName, atIndex: 18, effectiveRange: &range) as? Int).to(equal(NSUnderlineStyle.StyleSingle.rawValue))
                }

                it("styles H1s using the theme") {
                    var range = NSRange(location: 0, length: 2)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 23, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(1)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 23, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }

                it("styles H2s using the theme") {
                    var range = NSRange(location: 0, length: 2)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 26, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(2)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 26, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }

                it("styles H3s using the theme") {
                    var range = NSRange(location: 0, length: 2)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 29, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(3)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 29, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }

                it("styles H4s using the theme") {
                    var range = NSRange(location: 0, length: 2)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 32, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(4)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 32, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }

                it("styles H5s using the theme") {
                    var range = NSRange(location: 0, length: 2)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 35, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(5)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 35, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }

                it("styles H6s using the theme") {
                    var range = NSRange(location: 0, length: 2)
                    expect(attributedString.attribute(NSFontAttributeName, atIndex: 38, effectiveRange: &range) as? UIFont).to(equal(UIFont.systemFontOfSize(6)))
                    expect(attributedString.attribute(NSForegroundColorAttributeName, atIndex: 38, effectiveRange: &range) as? UIColor).to(equal(UIColor.magentaColor()))
                }
            }
        }
    }
}

private class FakeCMMarkdownTheme: FakeTheme {
    private override func markdownBodyFont() -> UIFont { return UIFont.systemFontOfSize(666) }
    private override func markdownBodyTextColor() -> UIColor { return UIColor.magentaColor() }
    private override func markdownBodyLinkTextColor() -> UIColor { return UIColor.purpleColor() }
    private override func markdownH1Font() -> UIFont { return UIFont.systemFontOfSize(1) }
    private override func markdownH2Font() -> UIFont { return UIFont.systemFontOfSize(2) }
    private override func markdownH3Font() -> UIFont { return UIFont.systemFontOfSize(3) }
    private override func markdownH4Font() -> UIFont { return UIFont.systemFontOfSize(4) }
    private override func markdownH5Font() -> UIFont { return UIFont.systemFontOfSize(5) }
    private override func markdownH6Font() -> UIFont { return UIFont.systemFontOfSize(6) }
    private override func defaultBodyTextLineHeight() -> CGFloat { return 666.0 }
}
