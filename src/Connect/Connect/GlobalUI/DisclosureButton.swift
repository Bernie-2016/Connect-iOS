import UIKit

class DisclosureButton: UIButton {
    let disclosureView = DisclosureIndicatorView.newAutoLayoutView()
    let title = UILabel.newAutoLayoutView()
    let subTitle = UILabel.newAutoLayoutView()

    private let defaultMargin: CGFloat


    override init(frame: CGRect) {
        self.defaultMargin = 20

        super.init(frame: frame)

        backgroundColor = UIColor.magentaColor()

        self.addSubview(disclosureView)
        self.addSubview(title)
        self.addSubview(subTitle)

        subTitle.numberOfLines = 2
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private func setupConstraints() {
        title.autoPinEdgeToSuperviewEdge(.Left)
        title.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultMargin)
        title.autoPinEdgeToSuperviewEdge(.Top, withInset: 15)

        disclosureView.autoPinEdge(.Top, toEdge: .Top, ofView: title)
        disclosureView.autoPinEdge(.Left, toEdge: .Right, ofView: title, withOffset: 5)
        disclosureView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureView.autoSetDimension(.Height, toSize: 20)

        subTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: title, withOffset: 6)
        subTitle.autoPinEdgeToSuperviewEdge(.Left)
        subTitle.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultMargin)
        subTitle.autoPinEdgeToSuperviewEdge(.Bottom)
    }
}
