import UIKit
import CocoaMarkdown

class ActionAlertController: UIViewController {
    private let actionAlert: ActionAlert
    private let markdownConverter: MarkdownConverter
    private let theme: Theme

    private let scrollView = UIScrollView.newAutoLayoutView()
    private let containerView = UIView.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let bodyTextView = UITextView.newAutoLayoutView()

    private var containerViewWidthConstraint: NSLayoutConstraint!

    init(actionAlert: ActionAlert, markdownConverter: MarkdownConverter, theme: Theme) {
        self.actionAlert = actionAlert
        self.markdownConverter = markdownConverter
        self.theme = theme

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(bodyTextView)

        dateLabel.text = actionAlert.date
        titleLabel.text = actionAlert.title
        bodyTextView.attributedText = markdownConverter.convertToAttributedString(actionAlert.body)

        bodyTextView.editable = false
        bodyTextView.selectable = true

        setupConstraints()

        view.backgroundColor = theme.contentBackgroundColor()
        dateLabel.font = theme.actionAlertDateFont()
        dateLabel.textColor = theme.actionAlertDateTextColor()
        titleLabel.font = theme.actionAlertTitleFont()
        titleLabel.textColor = theme.actionAlertTitleTextColor()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        let screenBounds = UIScreen.mainScreen().bounds
        containerViewWidthConstraint.constant = screenBounds.width
    }
    // MARK: Private

    private func setupConstraints() {
        let defaultHorizontalMargin: CGFloat = 15
        let defaultVerticalMargin: CGFloat = 21

        let screenBounds = UIScreen.mainScreen().bounds

        scrollView.contentSize.width = self.view.bounds.width
        scrollView.autoPinEdgesToSuperviewEdges()

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerViewWidthConstraint = containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        dateLabel.numberOfLines = 0
        dateLabel.preferredMaxLayoutWidth = screenBounds.width - defaultHorizontalMargin
        dateLabel.textAlignment = .Left
        dateLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultVerticalMargin)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        dateLabel.layoutIfNeeded()

        titleLabel.numberOfLines = 0
        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 5)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        bodyTextView.scrollEnabled = false
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.editable = false

        bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 10)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultVerticalMargin, relation: .GreaterThanOrEqual)
    }
}
