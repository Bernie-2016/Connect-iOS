import Foundation

class NewsFeedVideoTableViewCell: UITableViewCell {
    let titleLabel = UILabel.newAutoLayoutView()

    private let containerView = UIView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        self.contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)

        self.backgroundColor = UIColor.clearColor()

        containerView.backgroundColor = UIColor.whiteColor()

        self.accessoryType = .None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false

        titleLabel.numberOfLines = 3


        setupConstraints()
    }

    private func setupConstraints() {
        containerView.autoPinEdgesToSuperviewEdges()
        titleLabel.autoCenterInSuperview()
    }
}
