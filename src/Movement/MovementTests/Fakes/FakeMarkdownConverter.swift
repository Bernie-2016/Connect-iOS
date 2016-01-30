@testable import Movement

class FakeMarkdownConverter: MarkdownConverter {
    var lastReceivedMarkdown: String!
    let returnedAttributedString = NSAttributedString(string: "converted markdown")

    func convertToAttributedString(markdown: String) -> NSAttributedString {
        lastReceivedMarkdown = markdown
        return returnedAttributedString
    }
}
