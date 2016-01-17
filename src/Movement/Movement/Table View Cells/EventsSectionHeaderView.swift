import Foundation

class EventsSectionHeaderView: UITableViewHeaderFooterView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let f = textLabel!.frame
        let f2 = CGRect(x: 20, y: f.origin.y, width: f.size.width, height: f.size.height)
        textLabel!.frame = f2
    }
}
