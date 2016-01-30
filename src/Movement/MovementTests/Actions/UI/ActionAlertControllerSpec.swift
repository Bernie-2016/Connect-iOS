import Quick
import Nimble

@testable import Movement

class ActionAlertControllerSpec: QuickSpec {
    override func spec() {
        fdescribe("ActionAlertController") {
            var subject: ActionAlertController!
            var markdownConverter: FakeMarkdownConverter!
            var actionAlert: ActionAlert!

            beforeEach {
                actionAlert = TestUtils.actionAlert("Do the thing")

                markdownConverter = FakeMarkdownConverter()
                subject = ActionAlertController(
                    actionAlert: actionAlert,
                    markdownConverter: markdownConverter,
                    theme: FakeActionAlertControllerTheme()
                )

            }

            describe("when the view loads") {
                beforeEach {
                    expect(subject.view).toNot(beNil())
                }

                it("adds the screen content as subviews of a container view in a scroll view") {
                    expect(subject.view.subviews.count).to(equal(1))

                    let scrollView = subject.view.subviews.first!
                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))

                    let containerView = scrollView.subviews.first!

                    expect(containerView.subviews).to(contain(subject.dateLabel))
                    expect(containerView.subviews).to(contain(subject.titleLabel))
                    expect(containerView.subviews).to(contain(subject.bodyTextView))
                }

                it("sets the title label text from the action alert") {
                    expect(subject.titleLabel.text).to(equal("Do the thing"))
                }

                it("sets the body text view with text from the markdown converter") {
                    expect(markdownConverter.lastReceivedMarkdown).to(equal(actionAlert.body))
                    expect(subject.bodyTextView.attributedText.string).to(equal(markdownConverter.returnedAttributedString.string))
                }
                
                it("styles the non-body text content using the theme") {
                    expect(subject.view.backgroundColor).to(equal(UIColor.yellowColor()))
                    
                    expect(subject.dateLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                    expect(subject.dateLabel.textColor).to(equal(UIColor.magentaColor()))

                    expect(subject.dateLabel.font).to(equal(UIFont.systemFontOfSize(222)))
                    expect(subject.dateLabel.textColor).to(equal(UIColor.redColor()))
                }
            }
        }
    }
}

private class FakeActionAlertControllerTheme: FakeTheme {
    private override func actionAlertDateFont() -> UIFont {
        return UIFont.systemFontOfSize(111)
    }
    
    private override func actionAlertDateTextColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    private override func actionAlertTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(222)
    }
    
    private override func actionAlertTitleTextColor() -> UIColor {
        return UIColor.redColor()
    }
    
    private override func contentBackgroundColor() -> UIColor {
        return UIColor.yellowColor()
    }
}

