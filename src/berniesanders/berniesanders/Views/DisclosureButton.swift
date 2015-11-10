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
        title.autoPinEdgeToSuperviewMargin(.Top)

        disclosureView.autoPinEdge(.Top, toEdge: .Top, ofView: title, withOffset: 7)
        disclosureView.autoPinEdge(.Left, toEdge: .Right, ofView: title, withOffset: 5)
        disclosureView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureView.autoSetDimension(.Height, toSize: 20)

        subTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: title)
        subTitle.autoPinEdgeToSuperviewEdge(.Left)
        subTitle.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultMargin)
        subTitle.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5)
    }
}
