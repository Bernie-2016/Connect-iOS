import UIKit

class ActionAlertCell: UICollectionViewCell {
    let scrollView = UIScrollView.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let shortDescriptionLabel = UILabel.newAutoLayoutView()
    let webviewContainer = UIView.newAutoLayoutView()

    private let textContainerView = UIView.newAutoLayoutView()
    private let textGroupView = UIView.newAutoLayoutView()
    private let spacerView = UIView.newAutoLayoutView()

    private var webviewContainerHeightConstraint: NSLayoutConstraint?
    var webViewHeight: CGFloat {
        set {
            webviewContainerHeightConstraint!.constant = newValue
        }

        get {
            return webviewContainerHeightConstraint!.constant
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.numberOfLines = 2
        titleLabel.layoutMargins = UIEdgeInsetsZero
        shortDescriptionLabel.numberOfLines = 3
        shortDescriptionLabel.layoutMargins = UIEdgeInsetsZero

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        contentView.addSubview(scrollView)

        scrollView.addSubview(textContainerView)
        scrollView.addSubview(webviewContainer)
        scrollView.addSubview(spacerView)

        textContainerView.addSubview(textGroupView)
        textGroupView.addSubview(titleLabel)
        textGroupView.addSubview(shortDescriptionLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.autoPinEdgeToSuperviewEdge(.Top)
        scrollView.autoPinEdgeToSuperviewEdge(.Bottom)
        scrollView.autoPinEdgeToSuperviewEdge(.Left)
        scrollView.autoPinEdgeToSuperviewEdge(.Right)

        textContainerView.autoPinEdgeToSuperviewEdge(.Top, withInset: 20)
        textContainerView.autoPinEdgeToSuperviewEdge(.Left)
        textContainerView.autoSetDimension(.Height, toSize: 155)
        textContainerView.autoMatchDimension(.Width, toDimension: .Width, ofView: scrollView)

        textGroupView.autoPinEdgeToSuperviewEdge(.Left)
        textGroupView.autoPinEdgeToSuperviewEdge(.Right)
        textGroupView.autoAlignAxisToSuperviewAxis(.Horizontal)

        titleLabel.autoPinEdgeToSuperviewEdge(.Top)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 5)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 5)

        shortDescriptionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel)
        shortDescriptionLabel.autoPinEdge(.Left, toEdge: .Left, ofView: titleLabel)
        shortDescriptionLabel.autoPinEdge(.Right, toEdge: .Right, ofView: titleLabel)
        shortDescriptionLabel.autoPinEdgeToSuperviewEdge(.Bottom)

        webviewContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: textContainerView)
        webviewContainer.autoPinEdgeToSuperviewEdge(.Left)
        webviewContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: scrollView)
        webviewContainerHeightConstraint = webviewContainer.autoSetDimension(.Height, toSize: 0)

        spacerView.autoPinEdge(.Top, toEdge: .Bottom, ofView: webviewContainer)
        spacerView.autoPinEdgeToSuperviewEdge(.Left)
        spacerView.autoMatchDimension(.Width, toDimension: .Width, ofView: scrollView)
        spacerView.autoSetDimension(.Height, toSize: 65, relation: .GreaterThanOrEqual)
        spacerView.autoPinEdgeToSuperviewEdge(.Bottom)
    }
}
