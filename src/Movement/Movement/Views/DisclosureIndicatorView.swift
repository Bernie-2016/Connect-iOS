import UIKit

class DisclosureIndicatorView: UIView {
    var color: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    init() {
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(0.79, 0.67))
        bezier2Path.addLineToPoint(CGPointMake(5.67, 6.5))
        bezier2Path.addLineToPoint(CGPointMake(0.79, 12.31))
        color!.setStroke()
        bezier2Path.lineWidth = 2
        bezier2Path.stroke()
    }
}
