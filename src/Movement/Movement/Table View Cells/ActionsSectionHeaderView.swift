import Foundation

class ActionsSectionHeaderView: UITableViewHeaderFooterView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let f = textLabel!.frame
        let f2 = CGRect(x: 20, y: f.origin.y + 4, width: f.size.width, height: f.size.height)
        textLabel!.frame = f2
    }
}
