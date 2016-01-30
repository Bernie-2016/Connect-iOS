import CocoaMarkdown

protocol MarkdownConverter {
    func convertToAttributedString(markdown: String) -> NSAttributedString
}

class CMMarkdownConverter: MarkdownConverter {
    let attributes: CMTextAttributes
    init(theme: Theme) {
        attributes = CMTextAttributes()
        attributes.textAttributes = [
            NSFontAttributeName: theme.actionAlertBodyFont(),
            NSForegroundColorAttributeName: theme.actionAlertBodyTextColor()
        ]

        attributes.linkAttributes = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSForegroundColorAttributeName: theme.actionAlertBodyLinkTextColor()
        ]

        attributes.h1Attributes = [ NSFontAttributeName: theme.actionAlertH1Font() ]
        attributes.h2Attributes = [ NSFontAttributeName: theme.actionAlertH2Font() ]
        attributes.h3Attributes = [ NSFontAttributeName: theme.actionAlertH3Font() ]
        attributes.h4Attributes = [ NSFontAttributeName: theme.actionAlertH4Font() ]
        attributes.h5Attributes = [ NSFontAttributeName: theme.actionAlertH5Font() ]
        attributes.h6Attributes = [ NSFontAttributeName: theme.actionAlertH6Font() ]
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
