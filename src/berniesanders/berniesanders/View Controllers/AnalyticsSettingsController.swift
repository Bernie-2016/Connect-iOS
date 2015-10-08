import UIKit

public class AnalyticsSettingsController: UIViewController {
    private let applicationSettingsRepository: ApplicationSettingsRepository
    private let analyticsService: AnalyticsService
    private let theme: Theme
    
    private let scrollView = UIScrollView.newAutoLayoutView()
    private let containerView = UIView.newAutoLayoutView()
    private let spacerView = UIView.newAutoLayoutView()
    public let analyticsExplanationLabel = UILabel.newAutoLayoutView()
    public let analyticsSwitch = UISwitch.newAutoLayoutView()
    public let analyticsStateLabel = UILabel.newAutoLayoutView()
    
    public init(
        applicationSettingsRepository: ApplicationSettingsRepository,
        analyticsService: AnalyticsService,
        theme: Theme
        ) {
            self.applicationSettingsRepository = applicationSettingsRepository
            self.analyticsService = analyticsService
            self.theme = theme
            
            super.init(nibName: nil, bundle: nil)
            
            self.title = NSLocalizedString("Settings_analytics_title", comment: "")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(analyticsExplanationLabel)
        containerView.addSubview(analyticsSwitch)
        containerView.addSubview(analyticsStateLabel)
        containerView.addSubview(spacerView)
        
        analyticsExplanationLabel.numberOfLines = 0
        analyticsExplanationLabel.text = NSLocalizedString("Settings_analytics_explanation", comment:"")

        analyticsStateLabel.numberOfLines = 1
        analyticsStateLabel.text = NSLocalizedString("Settings_analytics_stateLoading", comment:"")
        
        analyticsSwitch.enabled = false
        analyticsSwitch.addTarget(self, action: "didTapAnalyticsSwitch:", forControlEvents: .TouchUpInside)
        
        applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            self.analyticsSwitch.enabled = true
            self.analyticsSwitch.on = analyticsEnabled
            self.analyticsStateLabel.text = NSLocalizedString(analyticsEnabled ? "Settings_analytics_stateEnabled" : "Settings_analytics_stateDisabled", comment:"")
        }
        
        applyTheme()
        setupConstraints()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    func didTapAnalyticsSwitch(sender: UISwitch) {
        applicationSettingsRepository.updateAnalyticsPermission(sender.on)
        let eventName = sender.on ? "User enabled analytics" : "User disabled analytics"
        analyticsService.trackCustomEventWithName(eventName, customAttributes: nil)
        self.analyticsStateLabel.text = NSLocalizedString(sender.on ? "Settings_analytics_stateEnabled" : "Settings_analytics_stateDisabled", comment:"")
    }
    
    // MARK: Private
    
    func setupConstraints() {
        let screenBounds = UIScreen.mainScreen().bounds
        
        scrollView.contentSize.width = self.view.bounds.width
        scrollView.autoPinEdgeToSuperviewEdge(.Top, withInset: 8)
        scrollView.autoPinEdgeToSuperviewEdge(.Left)
        scrollView.autoPinEdgeToSuperviewEdge(.Right)
        scrollView.autoPinEdgeToSuperviewEdge(.Bottom)
        
        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerView.autoSetDimension(.Width, toSize: screenBounds.width)
        
        analyticsExplanationLabel.autoPinEdgesToSuperviewMarginsExcludingEdge(.Bottom)
        analyticsSwitch.autoPinEdge(.Top, toEdge: .Bottom, ofView: analyticsExplanationLabel, withOffset: 16)
        analyticsSwitch.autoPinEdgeToSuperviewMargin(.Left)
        
        analyticsStateLabel.autoPinEdge(.Left, toEdge: .Right, ofView: analyticsSwitch, withOffset: 16)
        analyticsStateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: analyticsExplanationLabel, withOffset: 21)
        
        spacerView.autoPinEdgeToSuperviewMargin(.Bottom)
        spacerView.autoPinEdge(.Top, toEdge: .Bottom, ofView: analyticsStateLabel)
    }
    
    private func applyTheme() {
        view.backgroundColor = theme.defaultBackgroundColor()
        analyticsExplanationLabel.font = theme.settingsAnalyticsFont()
        analyticsStateLabel.font = theme.settingsAnalyticsFont()
    }
}
