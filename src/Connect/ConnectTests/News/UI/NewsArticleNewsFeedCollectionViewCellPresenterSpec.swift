import Quick
import Nimble

@testable import Connect

class NewsArticleNewsFeedCollectionViewCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("NewsArticleNewsFeedCollectionViewCellPresenter") {
            var subject: NewsArticleNewsFeedCollectionViewCellPresenter!

            var collectionView: UICollectionView!
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            var dataSource: UICollectionViewDataSource!
            beforeEach {
                subject = NewsArticleNewsFeedCollectionViewCellPresenter()

                collectionView = UICollectionView(
                    frame: CGRect.zero,
                    collectionViewLayout: UICollectionViewFlowLayout()
                )

                dataSource = FakeDataSource()
                collectionView.dataSource = dataSource
            }

            describe("presenting a news article") {
                let newsArticle = NewsArticle(title: "Bernie to release new album", date: NSDate(), body: "yeahhh", excerpt: "excerpt A", imageURL: NSURL(string: "http://bs.com")!, url: NSURL())

                beforeEach {
                    subject.setupCollectionView(collectionView)
                }

                it("sets the title label using the provided news article") {
                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                    expect(cell.titleLabel.text).to(equal("Bernie to release new album"))
                }
            }

            describe("presenting a non-news article") {
                beforeEach {
                    subject.setupCollectionView(collectionView)
                }

                it("returns nil") {
                    let otherNewsFeedItem = FakeNewsFeedItem()

                    expect(subject.cellForCollectionView(collectionView, newsFeedItem: otherNewsFeedItem, indexPath: indexPath)).to(beNil())
                }
            }
        }
    }
}

private class FakeNewsFeedItem: NewsFeedItem {
    var title = ""
    var date = NSDate()
    var identifier = ""
}

private class NewsFeedArticlePresenterFakeTheme : FakeTheme {
    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func newsFeedExcerptFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(21)
    }

    override func newsFeedExcerptColor() -> UIColor {
        return UIColor.redColor()
    }

    override func newsFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)    }

    override func defaultDisclosureColor() -> UIColor {
        return UIColor.brownColor()
    }

    override func highlightDisclosureColor() -> UIColor {
        return UIColor.whiteColor()
    }
}

private class FakeDataSource: NSObject, UICollectionViewDataSource {
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
