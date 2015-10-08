import Foundation
import Quick
import Nimble
import berniesanders

class WelcomeFakeTheme: FakeTheme {
    override func defaultBackgroundColor() -> UIColor { return UIColor.greenColor() }
    override func defaultButtonBackgroundColor() -> UIColor { return UIColor.redColor() }
    override func defaultButtonFont() -> UIFont { return UIFont.italicSystemFontOfSize(222) }
    override func defaultButtonTextColor() -> UIColor { return UIColor.yellowColor() }
    override func welcomeLabelFont() -> UIFont { return UIFont.italicSystemFontOfSize(111) }
    override func viewPolicyBackgroundColor() -> UIColor { return UIColor.magentaColor() }
    override func agreeToTermsLabelFont() -> UIFont { return UIFont.italicSystemFontOfSize(333) }
}

class FakeOnboardingRouter: OnboardingRouter {
    var hasFinishedOnboarding = false
    var lastControllerToFinishOnboarding: UIViewController!
    
    init() {
        super.init(
            termsAndConditionsAgreementRepository: FakeTermsAndConditionsAgreementRepository(),
            onboardingController: UIViewController(),
            postOnboardingController: UIViewController()
        )
    }
    
    override internal func controllerDidFinishOnboarding(controller: UIViewController) {
        hasFinishedOnboarding = true
        lastControllerToFinishOnboarding = controller
    }
}

class WelcomeControllerSpec: QuickSpec {
    var subject: WelcomeController!
    var onboardingRouter: FakeOnboardingRouter!
    var termsAndConditionsAgreementRepository: FakeTermsAndConditionsAgreementRepository!
    let termsAndConditionsController = TestUtils.termsAndConditionsController()
    let privacyPolicyController = TestUtils.privacyPolicyController()
    var analyticsService: FakeAnalyticsService!
    let theme = WelcomeFakeTheme()

    var navigationController: UINavigationController!
    
    override func spec() {
        describe("WelcomeController") {
            beforeEach {
                self.termsAndConditionsAgreementRepository = FakeTermsAndConditionsAgreementRepository()
                self.analyticsService = FakeAnalyticsService()
                self.onboardingRouter = FakeOnboardingRouter()
                
                self.subject = WelcomeController(
                    termsAndConditionsAgreementRepository: self.termsAndConditionsAgreementRepository,
                    termsAndConditionsController: self.termsAndConditionsController,
                    privacyPolicyController: self.privacyPolicyController,
                    analyticsService: self.analyticsService,
                    theme: self.theme
                )
                
                self.subject.onboardingRouter = self.onboardingRouter
                
                self.navigationController = UINavigationController()
                self.navigationController.pushViewController(self.subject, animated: false)
            }
            
            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("has a scroll view containing the UI elements") {
                    expect(self.subject.view.subviews.count).to(equal(1))
                    var scrollView = self.subject.view.subviews.first as! UIScrollView
                    
                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                    expect(scrollView.subviews.count).to(equal(1))
                    
                    var containerView = scrollView.subviews.first as! UIView
                    
                    expect(containerView.subviews.count).to(equal(6))
                    
                    var containerViewSubViews = containerView.subviews as! [UIView]
                    let subViews = self.subject.view.subviews as! [UIView]

                    expect(contains(containerViewSubViews, self.subject.bannerImageView)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.welcomeTextLabel)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.viewPrivacyPolicyButton)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.viewTermsButton)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.agreeToTermsNoticeLabel)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.agreeToTermsButton)).to(beTrue())
                }
                
                it("has the correct image in the banner image view") {
                    expect(self.subject.bannerImageView.image).to(equal(UIImage(named: "welcomeBanner")))
                }
                
                it("has a label with some welcome text") {
                    expect(self.subject.welcomeTextLabel.text).to(contain("Bernie Sanders is the fastest"))
                }
                
                it("has a button for viewing the privacy policy") {
                    expect(self.subject.viewPrivacyPolicyButton.titleForState(.Normal)).to(equal("Privacy Policy"))
                }
                
                describe("tapping on the view privacy policy button") {
                    beforeEach {
                        self.subject.viewPrivacyPolicyButton.tap()
                    }
                    
                    it("should push a correctly configured news item view controller onto the nav stack") {
                        expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.privacyPolicyController))
                    }
                    
                    it("should log a content view with the analytics service") {
                        expect(self.analyticsService.lastContentViewName).to(equal("Privacy Policy"))
                        expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Onboarding))
                        expect(self.analyticsService.lastContentViewID).to(equal("Privacy Policy"))
                    } 
                }
                
                it("has a button for viewing the terms") {
                    expect(self.subject.viewTermsButton.titleForState(.Normal)).to(equal("Terms and Conditions"))
                }
                
                describe("tapping on the view terms button") {
                    beforeEach {
                        self.subject.viewTermsButton.tap()
                    }
                    
                    it("should push a correctly configured news item view controller onto the nav stack") {
                        expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.termsAndConditionsController))
                    }
                    
                    it("should log a content view with the analytics service") {
                        expect(self.analyticsService.lastContentViewName).to(equal("Terms and Conditions"))
                        expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Onboarding))
                        expect(self.analyticsService.lastContentViewID).to(equal("Terms and Conditions"))
                    }
                }
                
                it("has a label informing the user to agree to the terms to continue") {
                    expect(self.subject.agreeToTermsNoticeLabel.text).to(equal("By tapping continue, you confirm that you have read our Terms and Conditions and Privacy Policy. This app is not affiliated with or authorized by Bernie 2016."))
                }
                
                it("has a button for agreeing to the terms and conditions") {
                    expect(self.subject.agreeToTermsButton.titleForState(.Normal)).to((equal("Continue to #feelthebern")))
                }
                
                describe("tapping on the agree to terms button") {
                    beforeEach {
                        self.subject.agreeToTermsButton.tap()
                    }
                    
                    it("opens tells the terms agreement repository that the user agreed to terms") {
                        expect(self.termsAndConditionsAgreementRepository.hasAgreedToTerms).to(beTrue())
                    }
                    
                    it("logs that the user tapped the coders button") {
                        expect(self.analyticsService.lastCustomEventName).to(equal("User agreed to Terms and Conditions"))
                        expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                    }
                    
                    context("when the terms agreement repository confirms that the user agreed to terms") {
                        it("tells the onboarding router that the user finished onboarding") {
                            expect(self.onboardingRouter.hasFinishedOnboarding).to(beTrue())
                            expect(self.onboardingRouter.lastControllerToFinishOnboarding).to(beIdenticalTo(self.subject))
                        }
                    }
                }
                
                describe("when the view appears") {
                    beforeEach {
                        self.subject.viewWillAppear(false)
                    }
                    
                    it("hides the navigation bar") {
                        expect(self.subject.navigationController!.navigationBarHidden).to(beTrue())
                    }
                }
                
                it("styles the view components with the theme") {
                    expect(self.subject.view.backgroundColor).to(equal(UIColor.greenColor()))
                    
                    expect(self.subject.welcomeTextLabel.font).to(equal(UIFont.italicSystemFontOfSize(111)))
                    
                    expect(self.subject.viewTermsButton.backgroundColor).to(equal(UIColor.magentaColor()))
                    expect(self.subject.viewTermsButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(self.subject.viewTermsButton.titleColorForState(.Normal)).to(equal(UIColor.yellowColor()))
                    
                    expect(self.subject.viewPrivacyPolicyButton.backgroundColor).to(equal(UIColor.magentaColor()))
                    expect(self.subject.viewPrivacyPolicyButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(self.subject.viewPrivacyPolicyButton.titleColorForState(.Normal)).to(equal(UIColor.yellowColor()))
                    
                    expect(self.subject.agreeToTermsNoticeLabel.font).to(equal(UIFont.italicSystemFontOfSize(333)))

                    expect(self.subject.agreeToTermsButton.backgroundColor).to(equal(UIColor.redColor()))
                    expect(self.subject.agreeToTermsButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(self.subject.agreeToTermsButton.titleColorForState(.Normal)).to(equal(UIColor.yellowColor()))
                }
            }
        }
    }
}
