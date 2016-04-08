import UIKit

class ActionAlertCell: UICollectionViewCell {
    let scrollView = UIScrollView.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let shortDescriptionLabel = UILabel.newAutoLayoutView()
    let shareButton = UIButton.newAutoLayoutView()

    let webviewContainer = UIView.newAutoLayoutView()
    let activityIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    private let spacerView = UIView.newAutoLayoutView()

    private let shortDescriptionLabelOffset: CGFloat = 5

    private var webviewContainerHeightConstraint: NSLayoutConstraint?
    var webViewHeight: CGFloat {
        set {
            webviewContainerHeightConstraint!.constant = newValue
        }

        get {
            return webviewContainerHeightConstraint!.constant
        }
    }

    private var shortDescriptionOffsetConstraint: NSLayoutConstraint?
    var shortDescriptionText: String {
        set {
            shortDescriptionLabel.text = newValue

            let offset = newValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 ? 0 : shortDescriptionLabelOffset
            shortDescriptionOffsetConstraint!.constant = offset
        }

        get {
            return shortDescriptionLabel.text!
        }
    }

    private var shareButtonHeightConstraint: NSLayoutConstraint?
    var shareButtonVisible: Bool {
        set {
            shareButton.hidden = !newValue
//            shareButtonHeightConstraint!.active = !newValue
        }
        get {
            return !shareButton.hidden
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.numberOfLines = 0
        titleLabel.layoutMargins = UIEdgeInsetsZero
        titleLabel.textAlignment = .Center

        shortDescriptionLabel.numberOfLines = 0
        shortDescriptionLabel.layoutMargins = UIEdgeInsetsZero
        shortDescriptionLabel.textAlignment = .Center

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        contentView.addSubview(scrollView)

        scrollView.addSubview(activityIndicatorView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(shortDescriptionLabel)
        scrollView.addSubview(webviewContainer)
        scrollView.addSubview(shareButton)
        scrollView.addSubview(spacerView)

        activityIndicatorView.startAnimating()

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.autoPinEdgeToSuperviewEdge(.Top)
        scrollView.autoPinEdgeToSuperviewEdge(.Bottom)
        scrollView.autoPinEdgeToSuperviewEdge(.Left)
        scrollView.autoPinEdgeToSuperviewEdge(.Right)

        titleLabel.autoPinEdgeToSuperviewEdge(.Top)
        titleLabel.autoPinEdge(.Left, toEdge: .Left, ofView: webviewContainer, withOffset: 5)
        titleLabel.autoPinEdge(.Right, toEdge: .Right, ofView: webviewContainer, withOffset: -5)

        shortDescriptionOffsetConstraint = shortDescriptionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: shortDescriptionLabelOffset)
        shortDescriptionLabel.autoPinEdge(.Left, toEdge: .Left, ofView: titleLabel)
        shortDescriptionLabel.autoPinEdge(.Right, toEdge: .Right, ofView: titleLabel)

        webviewContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: shortDescriptionLabel, withOffset: 20)
        webviewContainer.autoPinEdgeToSuperviewEdge(.Left)
        webviewContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: scrollView)
        webviewContainerHeightConstraint = webviewContainer.autoSetDimension(.Height, toSize: 0)

        shareButton.autoAlignAxis(.Vertical, toSameAxisOfView: webviewContainer)
        shareButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: webviewContainer, withOffset: 0)
        shareButtonHeightConstraint = shareButton.autoSetDimension(.Height, toSize: 0)

        activityIndicatorView.autoPinEdge(.Top, toEdge: .Top, ofView: webviewContainer, withOffset: 30)
        activityIndicatorView.autoAlignAxis(.Vertical, toSameAxisOfView: webviewContainer)

        spacerView.autoPinEdge(.Top, toEdge: .Bottom, ofView: shareButton)
        spacerView.autoPinEdgeToSuperviewEdge(.Left)
        spacerView.autoMatchDimension(.Width, toDimension: .Width, ofView: scrollView)
        spacerView.autoSetDimension(.Height, toSize: 130, relation: .GreaterThanOrEqual)
        spacerView.autoPinEdgeToSuperviewEdge(.Bottom)
    }
}
