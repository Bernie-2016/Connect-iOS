import berniesanders
import Quick
import Nimble
import UIKit

class NewsFakeTheme : FakeTheme {
    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }
    
    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    override func newsFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)    }
    
    override func newsFeedDateColor() -> UIColor {
        return UIColor.brownColor()
    }
    
    override func tabBarTextColor() -> UIColor {
        return UIColor.purpleColor()
    }
    
    override func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
}

class FakeNewsItemRepository : berniesanders.NewsItemRepository {
    var lastCompletionBlock: ((Array<NewsItem>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchNewsCalled: Bool = false
    
    init() {
    }

    func fetchNewsItems(completion: (Array<NewsItem>) -> Void, error: (NSError) -> Void) {
        self.fetchNewsCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class FakeNewsItemControllerProvider : berniesanders.NewsItemControllerProvider {
    let controller = NewsItemController(newsItem: NewsItem(title: "a", date: NSDate(), body: "a body", imageURL: NSURL()), dateFormatter: NSDateFormatter(), imageRepository: FakeImageRepository(), theme: FakeTheme())
    var lastNewsItem: NewsItem?
    
    func provideInstanceWithNewsItem(newsItem: NewsItem) -> NewsItemController {
        self.lastNewsItem = newsItem;
        return self.controller
    }
}

class NewsTableViewControllerSpecs: QuickSpec {
    var subject: NewsTableViewController!
    let navigationController = UINavigationController()
    let newsItemRepository: FakeNewsItemRepository! =  FakeNewsItemRepository()
    let theme: Theme! = NewsFakeTheme()
    let newsItemControllerProvider = FakeNewsItemControllerProvider()
    
    override func spec() {
        beforeEach {
            let theme = NewsFakeTheme()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            
            self.subject = NewsTableViewController(
                theme: theme,
                newsItemRepository: self.newsItemRepository,
                dateFormatter: dateFormatter,
                newsItemControllerProvider: self.newsItemControllerProvider
            )
            
            self.navigationController.pushViewController(self.subject, animated: false)
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("News"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("HOME"))
        }
        
        it("styles its tab bar item from the theme") {
            let normalAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Normal)
            
            let normalTextColor = normalAttributes[NSForegroundColorAttributeName] as! UIColor
            let normalFont = normalAttributes[NSFontAttributeName] as! UIFont
            
            expect(normalTextColor).to(equal(UIColor.purpleColor()))
            expect(normalFont).to(equal(UIFont.systemFontOfSize(123)))
            
            let selectedAttributes = self.subject.tabBarItem.titleTextAttributesForState(UIControlState.Selected)
            
            let selectedTextColor = selectedAttributes[NSForegroundColorAttributeName] as! UIColor
            let selectedFont = selectedAttributes[NSFontAttributeName] as! UIFont
            
            expect(selectedTextColor).to(equal(UIColor.purpleColor()))
            expect(selectedFont).to(equal(UIFont.systemFontOfSize(123)))
        }
        
        describe("when the controller appears") {
            beforeEach {
                self.subject.view.layoutIfNeeded()
                self.subject.viewWillAppear(false)
            }
            
            it("has an empty table") {
                expect(self.subject.tableView.numberOfSections()).to(equal(1))
                expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(0))
            }
            
            it("asks the news repository for some news") {
                expect(self.newsItemRepository.fetchNewsCalled).to(beTrue())
            }
            
            describe("when the news repository returns some news items", {
                var newsItemADate = NSDate(timeIntervalSince1970: 0)
                var newsItemBDate = NSDate(timeIntervalSince1970: 86401)
                
                beforeEach {
                    var newsItemA = NewsItem(title: "Bernie to release new album", date: newsItemADate, body: "yeahhh", imageURL: NSURL())
                    var newsItemB = NewsItem(title: "Bernie up in the polls!", date: newsItemBDate, body: "body text", imageURL: NSURL())

                    var newsItems = [newsItemA, newsItemB]
                    self.newsItemRepository.lastCompletionBlock!(newsItems)
                }
                
                it("shows the items in the table with upcased text") {
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))
                    
                    var cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellA.titleLabel.text).to(equal("BERNIE TO RELEASE NEW ALBUM"))
                    expect(cellA.dateLabel.text).to(equal("1/1/70"))
                    
                    var cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellB.titleLabel.text).to(equal("BERNIE UP IN THE POLLS!"))
                    expect(cellB.dateLabel.text).to(equal("1/2/70"))
                }
                
                it("styles the items in the table") {
                    var cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TitleSubTitleTableViewCell
                    
                    expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                    expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    expect(cell.dateLabel.textColor).to(equal(UIColor.brownColor()))
                    expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                }
            })
        }
        
        describe("Tapping on a news item") {
            let expectedNewsItem = NewsItem(title: "B", date: NSDate(), body: "B Body", imageURL: NSURL())
            
            beforeEach {
                self.subject.view.layoutIfNeeded()
                self.subject.viewWillAppear(false)
                var newsItemA = NewsItem(title: "A", date: NSDate(), body: "A Body", imageURL: NSURL())
            
                var newsItems = [newsItemA, expectedNewsItem]
                
                self.newsItemRepository.lastCompletionBlock!(newsItems)
            }
            
            xit("should push a correctly configured news item view controller onto the nav stack") {
                // PENDING: need to pull in PCK
                
                let tableView = self.subject.tableView
                                println(self.navigationController.topViewController)
                tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                
                println(self.navigationController.topViewController)
                println(self.subject.navigationController)
                println(self.subject.navigationController?.topViewController)
                expect(self.newsItemControllerProvider.lastNewsItem).to(beIdenticalTo(expectedNewsItem))
                expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.newsItemControllerProvider.controller))
            }
        }
    }
}

