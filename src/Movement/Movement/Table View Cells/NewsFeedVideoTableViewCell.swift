import Foundation

class NewsFeedVideoTableViewCell: UITableViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let descriptionLabel = UILabel.newAutoLayoutView()
    let thumbnailImageView = UIImageView.newAutoLayoutView()
    let disclosureView = DisclosureIndicatorView.newAutoLayoutView()

    private let containerView = UIView.newAutoLayoutView()
    private let defaultMargin: CGFloat = 20

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(disclosureView)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(thumbnailImageView)
        containerView.clipsToBounds = true

        backgroundColor = UIColor.clearColor()

        containerView.backgroundColor = UIColor.whiteColor()

        accessoryType = .None
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false

        titleLabel.numberOfLines = 3
        descriptionLabel.numberOfLines = 3

        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .ScaleAspectFill

        setupConstraints()
    }

    private func setupConstraints() {
        containerView.autoPinEdgeToSuperviewEdge(.Top, withInset: 11)
        containerView.autoPinEdgeToSuperviewEdge(.Left)
        containerView.autoPinEdgeToSuperviewEdge(.Right)
        containerView.autoPinEdgeToSuperviewEdge(.Bottom)

        let screenBounds = UIScreen.mainScreen().bounds

        thumbnailImageView.autoPinEdgeToSuperviewEdge(.Top)
        thumbnailImageView.autoPinEdgeToSuperviewEdge(.Right)
        thumbnailImageView.autoPinEdgeToSuperviewEdge(.Left)
        thumbnailImageView.autoSetDimension(.Height, toSize: screenBounds.width / 1.7777)

        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: thumbnailImageView, withOffset: 5)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultMargin)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 50)

        dateLabel.autoPinEdge(.Top, toEdge: .Top, ofView: titleLabel, withOffset: 5)
        dateLabel.autoPinEdge(.Left, toEdge: .Right, ofView: titleLabel, withOffset: 5)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultMargin)

        disclosureView.autoPinEdge(.Top, toEdge: .Top, ofView: dateLabel, withOffset: 1)
        disclosureView.autoPinEdge(.Left, toEdge: .Right, ofView: dateLabel, withOffset: 5)
        disclosureView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureView.autoSetDimension(.Height, toSize: 20)

        descriptionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
        descriptionLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultMargin)
        descriptionLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultMargin)
        descriptionLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 50)
    }
}
