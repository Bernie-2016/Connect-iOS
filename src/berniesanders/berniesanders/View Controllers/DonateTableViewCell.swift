import UIKit
import PureLayout

class DonateTableViewCell: UITableViewCell {
    private var didSetupViews = false

    let messageView = UILabel.newAutoLayoutView()
    let buttonView = UILabel.newAutoLayoutView()


    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupViews(theme: Theme) {
        if didSetupViews {
            return
        }

        didSetupViews = true
        selectionStyle = .None

        contentView.addSubview(messageView)

        contentView.addSubview(buttonView)

        messageView.text = NSLocalizedString("Settings_donate_tableCellText", comment: "")
        messageView.textColor = theme.settingsTitleColor()
        messageView.font = theme.settingsTitleFont()

        messageView.lineBreakMode = NSLineBreakMode.ByWordWrapping
        messageView.textAlignment = NSTextAlignment.Center
        messageView.numberOfLines = 0

        buttonView.text = NSLocalizedString("Settings_donate_buttonText", comment: "")
        buttonView.textColor = theme.settingsDonateButtonTextColor()
        buttonView.font = theme.settingsDonateButtonFont()
        buttonView.textAlignment = NSTextAlignment.Center
        buttonView.backgroundColor = theme.settingsDonateButtonColor()
        buttonView.layer.cornerRadius = 5
        buttonView.layer.masksToBounds = true

        setupConstraintsAndLayout()

    }

    private func setupConstraintsAndLayout() {
        messageView.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 10)
        messageView.autoSetDimension(ALDimension.Width, toSize: 230)
        messageView.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)

        buttonView.autoSetDimension(ALDimension.Height, toSize: 40)
        buttonView.autoSetDimension(ALDimension.Width, toSize: 130)
        buttonView.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        buttonView.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: messageView, withOffset: 10)
        buttonView.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset:10)
    }
}
