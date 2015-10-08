import Quick
import Nimble
import berniesanders

class AnalyticsFakeTheme: FakeTheme {
    override func settingsAnalyticsFont() -> UIFont {
        return UIFont.systemFontOfSize(111)
    }
    
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.redColor()
    }
}

class AnalyticsSettingsControllerSpec: QuickSpec {
    var subject: AnalyticsSettingsController!
    var applicationSettingsRepository: FakeApplicationSettingsRepository!
    var analyticsService: FakeAnalyticsService!
    let theme = AnalyticsFakeTheme()
    
    override func spec() {
        describe("AnalyticsSettingsController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()
                self.applicationSettingsRepository = FakeApplicationSettingsRepository()
                
                self.subject = AnalyticsSettingsController(
                    applicationSettingsRepository: self.applicationSettingsRepository,
                    analyticsService: self.analyticsService,
                    theme: self.theme
                )
            }
            
            it("has the correct title") {
                expect(self.subject.title).to(equal("Analytics Settings"))
            }

            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("has all of the view components as subviews inside a scroll view") {
                    expect(self.subject.view.subviews.count).to(equal(1))
                    var scrollView = self.subject.view.subviews.first as! UIScrollView
                    
                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                    expect(scrollView.subviews.count).to(equal(1))
                    
                    var containerView = scrollView.subviews.first as! UIView

                    let subViews = containerView.subviews as! [UIView]
                    expect(subViews.count).to(equal(3 + 1)) // including spacer
                    
                    expect(contains(subViews, self.subject.analyticsExplanationLabel)).to(beTrue())
                    expect(contains(subViews, self.subject.analyticsSwitch)).to(beTrue())
                    expect(contains(subViews, self.subject.analyticsStateLabel)).to(beTrue())
                }
                
                it("has a label explaining the purpose of analytics") {
                    expect(self.subject.analyticsExplanationLabel.text).to(contain("We collect anonymous data about how you use this app"))
                }
                
                it("should initially disable the switch") {
                    expect(self.subject.analyticsSwitch.enabled).to(beFalse())
                }
                
                it("should query the app settings repo for the analytics permissions setting") {
                    self.applicationSettingsRepository.hasReceivedQueryForAnalytics
                }
                
                it("should set the state label to loading") {
                    expect(self.subject.analyticsStateLabel.text).to(equal("Loading..."))
                }
                
                it("styles the view components with the theme") {
                    expect(self.subject.view.backgroundColor).to(equal(UIColor.redColor()))
                    expect(self.subject.analyticsExplanationLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                    expect(self.subject.analyticsStateLabel.font).to(equal(UIFont.systemFontOfSize(111)))
                }
                
                context("when analytics are enabled") {
                    beforeEach {
                        self.applicationSettingsRepository.lastAnalyticsCompletionHandler(true)
                        
                    }
                    
                    it("should turn the switch on") {
                        expect(self.subject.analyticsSwitch.on).to(beTrue())
                    }
                    
                    it("should enable the switch") {
                        expect(self.subject.analyticsSwitch.enabled).to(beTrue())
                    }
                    
                    it("should set the state label to enabled") {
                        expect(self.subject.analyticsStateLabel.text).to(equal("Analytics enabled"))
                    }
                }
                
                context("when analytics are disabled") {
                    beforeEach {
                        self.applicationSettingsRepository.lastAnalyticsCompletionHandler(false)
                    }
                    
                    it("should turn the switch off") {
                        expect(self.subject.analyticsSwitch.on).to(beFalse())
                    }
                    
                    it("should enable the switch") {
                        expect(self.subject.analyticsSwitch.enabled).to(beTrue())
                    }
                    
                    it("should set the state label to enabled") {
                        expect(self.subject.analyticsStateLabel.text).to(equal("Analytics disabled"))
                    }
                }
                
                describe("tapping on the switch") {
                    beforeEach {
                        self.applicationSettingsRepository.lastAnalyticsCompletionHandler(false)
                    }

                    it("sends the new state to the application settings repository") {
                        self.subject.analyticsSwitch.on = true
                        self.subject.analyticsSwitch.tap()
                        
                        expect(self.applicationSettingsRepository.lastAnalyticsPermissionGrantedValue).to(beTrue())
                        
                        self.subject.analyticsSwitch.on = false
                        self.subject.analyticsSwitch.tap()
                        
                        expect(self.applicationSettingsRepository.lastAnalyticsPermissionGrantedValue).to(beFalse())
                    }
                    
                    it("logs the new state to the analytics service") {
                        // note that the analytics service uses this setting internally, 
                        // so we do not need to check it here
                        
                        self.subject.analyticsSwitch.on = true
                        self.subject.analyticsSwitch.tap()
                        
                        expect(self.analyticsService.lastCustomEventName).to(equal("User enabled analytics"))
                        
                        self.subject.analyticsSwitch.on = false
                        self.subject.analyticsSwitch.tap()

                        expect(self.analyticsService.lastCustomEventName).to(equal("User disabled analytics"))
                    }
                    
                    it("should update the state label") {
                        self.subject.analyticsSwitch.on = true
                        self.subject.analyticsSwitch.tap()

                        expect(self.subject.analyticsStateLabel.text).to(equal("Analytics enabled"))
                        
                        self.subject.analyticsSwitch.on = false
                        self.subject.analyticsSwitch.tap()

                        expect(self.subject.analyticsStateLabel.text).to(equal("Analytics disabled"))
                        
                        self.subject.analyticsSwitch.on = true
                        self.subject.analyticsSwitch.tap()
                        
                        expect(self.subject.analyticsStateLabel.text).to(equal("Analytics enabled"))
                    }
                }
            }
        }
    }
}
