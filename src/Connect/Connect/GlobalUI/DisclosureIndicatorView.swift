import UIKit

class DisclosureIndicatorView: UIView {
    var color: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPoint(x: 0.79, y: 0.67))
        bezier2Path.addLineToPoint(CGPoint(x: 5.67, y: 6.5))
        bezier2Path.addLineToPoint(CGPoint(x: 0.79, y: 12.31))
        color!.setStroke()
        bezier2Path.lineWidth = 2
        bezier2Path.stroke()
    }
}
