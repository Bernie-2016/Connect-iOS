import UIKit

// Inspired by http://blog.karmadust.com/centered-paging-with-preview-cells-on-uicollectionview/

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    let cellAspectRatio: CGFloat = 3/1

    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let rectBounds: CGRect = self.collectionView!.bounds
        let halfWidth: CGFloat = rectBounds.size.width * CGFloat(0.50)
        let proposedContentOffsetCenterX: CGFloat = proposedContentOffset.x + halfWidth
        let proposedRect: CGRect = self.collectionView!.bounds

        let attributesArray: NSArray = self.layoutAttributesForElementsInRect(proposedRect)!

        var candidateAttributes: UICollectionViewLayoutAttributes?


        for layoutAttributes: AnyObject in attributesArray {
            if let collectionViewLayoutAttributes = layoutAttributes as? UICollectionViewLayoutAttributes {
                if collectionViewLayoutAttributes.representedElementCategory != .Cell { continue }

                if candidateAttributes == nil {
                    candidateAttributes = collectionViewLayoutAttributes
                    continue
                }

                let distanceFromLayoutCenterXToProposedCenterX = fabsf(Float(collectionViewLayoutAttributes.center.x) - Float(proposedContentOffsetCenterX))
                let distanceFromCandidateCenterXToProposedContentOffsetCenterX = fabsf(Float(candidateAttributes!.center.x) - Float(proposedContentOffsetCenterX))

                if  distanceFromLayoutCenterXToProposedCenterX <  distanceFromCandidateCenterXToProposedContentOffsetCenterX {
                    candidateAttributes = collectionViewLayoutAttributes
                }

            }
        }

        let x = attributesArray.count == 0 ?  proposedContentOffset.x - halfWidth * 2 : candidateAttributes!.center.x - halfWidth

        return CGPoint(x: x, y: proposedContentOffset.y)
    }
}
