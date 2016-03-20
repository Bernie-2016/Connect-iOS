import UIKit

class ActionAlertCell: UICollectionViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let webviewContainer = UIView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)
        contentView.addSubview(webviewContainer)

        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 45)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right)

        webviewContainer.autoPinEdge(.Top, toEdge: .Top, ofView: contentView, withOffset: 135)
        webviewContainer.autoPinEdge(.Left, toEdge: .Left, ofView: contentView)
        webviewContainer.autoPinEdge(.Right, toEdge: .Right, ofView: contentView)
        webviewContainer.autoSetDimension(.Height, toSize: contentView.frame.size.height - 135)
    }
}
