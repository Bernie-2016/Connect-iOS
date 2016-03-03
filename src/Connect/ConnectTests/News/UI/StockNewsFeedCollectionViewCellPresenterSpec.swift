import Quick
import Nimble

@testable import Connect

class StockNewsFeedCellProviderSpec: QuickSpec {
    override func spec() {
        describe("StockNewsFeedCellProvider") {
            var subject: NewsFeedCellProvider!
            var childPresenterA: FakeNewsFeedCellProvider!
            var childPresenterB: FakeNewsFeedCellProvider!

            let layout =  UICollectionViewFlowLayout()
            layout.invalidateLayout()
            let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            let newsArticle = TestUtils.newsArticle()
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)


            beforeEach {
                childPresenterA = FakeNewsFeedCellProvider()
                childPresenterB = FakeNewsFeedCellProvider()

                subject = StockNewsFeedCellProvider(childPresenters: [childPresenterA, childPresenterB])
            }

            describe("setting up a collection view") {
                it("tells each configured presenter to setup the collection view") {
                    subject.setupCollectionView(collectionView)

                    expect(childPresenterA.lastSetupCollectionView) === collectionView
                    expect(childPresenterB.lastSetupCollectionView) === collectionView
                }
            }

            describe("presenting a news article") {
                it("returns the first presented cell from the child presenters") {
                    childPresenterA.returnNil = true

                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)

                    expect(childPresenterA.receivedCollectionViews) == [collectionView]
                    expect(childPresenterA.receivedNewsFeedItems.first as? NewsArticle) === newsArticle
                    expect(childPresenterA.receivedIndexPaths) == [indexPath]

                    expect(childPresenterB.receivedCollectionViews) == [collectionView]
                    expect(childPresenterB.receivedNewsFeedItems.first as? NewsArticle) === newsArticle
                    expect(childPresenterB.receivedIndexPaths) == [indexPath]

                    expect(cell) === childPresenterB.returnedCells.last
                }

                context("when no presenter returns a cell for the news article") {
                    it("returns nil") {
                        childPresenterA.returnNil = true
                        childPresenterB.returnNil = true

                        let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)

                        expect(cell).to(beNil())
                    }
                }
            }
        }
    }
}
