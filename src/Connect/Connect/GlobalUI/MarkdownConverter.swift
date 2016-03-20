import CocoaMarkdown

protocol MarkdownConverter {
    func convertToAttributedString(markdown: String) -> NSAttributedString
}

class CMMarkdownConverter: MarkdownConverter {
    let attributes: CMTextAttributes
    init(theme: Theme) {
        attributes = CMTextAttributes()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = theme.defaultBodyTextLineHeight()
        paragraphStyle.maximumLineHeight = theme.defaultBodyTextLineHeight()
        paragraphStyle.minimumLineHeight = theme.defaultBodyTextLineHeight()

        attributes.textAttributes = [
            NSFontAttributeName: theme.markdownBodyFont(),
            NSForegroundColorAttributeName: theme.markdownBodyTextColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]

        attributes.linkAttributes = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSForegroundColorAttributeName: theme.markdownBodyLinkTextColor()
        ]

        attributes.h1Attributes = [ NSFontAttributeName: theme.markdownH1Font() ]
        attributes.h2Attributes = [ NSFontAttributeName: theme.markdownH2Font() ]
        attributes.h3Attributes = [ NSFontAttributeName: theme.markdownH3Font() ]
        attributes.h4Attributes = [ NSFontAttributeName: theme.markdownH4Font() ]
        attributes.h5Attributes = [ NSFontAttributeName: theme.markdownH5Font() ]
        attributes.h6Attributes = [ NSFontAttributeName: theme.markdownH6Font() ]
    }

    func convertToAttributedString(markdown: String) -> NSAttributedString {
        let data = markdown.dataUsingEncoding(NSUTF8StringEncoding)
        let document = CMDocument(data: data, options: .Smart)
        let renderer = CMAttributedStringRenderer(document: document, attributes: attributes)

        renderer.registerHTMLElementTransformer(CMHTMLStrikethroughTransformer())
        renderer.registerHTMLElementTransformer(CMHTMLSuperscriptTransformer())
        renderer.registerHTMLElementTransformer(CMHTMLUnderlineTransformer())

        return renderer.render()
    }
}
