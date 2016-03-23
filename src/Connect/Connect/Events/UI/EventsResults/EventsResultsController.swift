import UIKit

class EventsResultsController: UIViewController {
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let eventControllerProvider: EventControllerProvider
    private let eventPresenter: EventPresenter
    private let eventSectionHeaderPresenter: EventSectionHeaderPresenter
    private let eventListTableViewCellStylist: EventListTableViewCellStylist
    private let resultQueue: NSOperationQueue
    private let analyticsService: AnalyticsService
    private let theme: Theme

    let tableView = UITableView.newAutoLayoutView()

    private var eventSearchResult: EventSearchResult!

    init(
        nearbyEventsUseCase: NearbyEventsUseCase,
        eventsNearAddressUseCase: EventsNearAddressUseCase,
        eventControllerProvider: EventControllerProvider,
        eventPresenter: EventPresenter,
        eventSectionHeaderPresenter: EventSectionHeaderPresenter,
        eventListTableViewCellStylist: EventListTableViewCellStylist,
        resultQueue: NSOperationQueue,
        analyticsService: AnalyticsService,
        theme: Theme) {
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.eventsNearAddressUseCase = eventsNearAddressUseCase
            self.eventControllerProvider = eventControllerProvider
            self.eventPresenter = eventPresenter
            self.eventSectionHeaderPresenter = eventSectionHeaderPresenter
            self.eventListTableViewCellStylist = eventListTableViewCellStylist
            self.resultQueue = resultQueue
            self.analyticsService = analyticsService
            self.theme = theme

            super.init(nibName: nil, bundle: nil)

            nearbyEventsUseCase.addObserver(self)
            eventsNearAddressUseCase.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(EventListTableViewCell.self, forCellReuseIdentifier: "eventCell")
        tableView.registerClass(EventsSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")

        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()

        if eventSearchResult?.events.count > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        }
    }

    private func setupConstraints() {
        tableView.autoPinEdgesToSuperviewEdges()
    }

    private func updateTableWithSearchResult(searchResult: EventSearchResult?) {
        resultQueue.addOperationWithBlock {
            self.eventSearchResult = searchResult
            self.tableView.reloadData()
        }
    }
}

extension EventsResultsController: EventsNearAddressUseCaseObserver {
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult, address: Address) {
        updateTableWithSearchResult(eventSearchResult)
    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents: EventsNearAddressUseCaseError, address: Address) {
        updateTableWithSearchResult(nil)
    }

    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address) {
        updateTableWithSearchResult(nil)
    }

    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address) {}
}

extension EventsResultsController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult) {
        updateTableWithSearchResult(eventSearchResult)
    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {
        updateTableWithSearchResult(nil)
    }

    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        updateTableWithSearchResult(nil)
    }

    func nearbyEventsUseCaseDidStartFetchingEvents(useCase: NearbyEventsUseCase) {}
}

extension EventsResultsController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return eventSearchResult != nil ? eventSearchResult.uniqueDaysInLocalTimeZone().count : 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventSearchResult != nil ? eventSearchResult.eventsWithDayIndex(section).count : 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: EventListTableViewCell! = tableView.dequeueReusableCellWithIdentifier("eventCell") as? EventListTableViewCell
        if cell == nil { cell = EventListTableViewCell() }

        let eventsForDay = eventSearchResult.eventsWithDayIndex(indexPath.section)
        let event = eventsForDay[indexPath.row]

        eventListTableViewCellStylist.styleCell(cell, event: event)

        return eventPresenter.presentEventListCell(event, cell: cell)
    }
}

extension EventsResultsController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") else {
            return nil
        }

        guard eventSearchResult != nil else { return nil }

        let sectionDate = eventSearchResult.uniqueDaysInLocalTimeZone()[section]
        header.textLabel!.text = eventSectionHeaderPresenter.headerForDate(sectionDate)
        return header
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.contentView.backgroundColor = theme.defaultTableSectionHeaderBackgroundColor()
        headerView.textLabel?.textColor = theme.defaultTableSectionHeaderTextColor()
        headerView.textLabel?.font = theme.defaultTableSectionHeaderFont()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let eventsForDay = eventSearchResult.eventsWithDayIndex(indexPath.section)
        let event = eventsForDay[indexPath.row]
        let controller = self.eventControllerProvider.provideInstanceWithEvent(event)
        self.analyticsService.trackContentViewWithName(event.name, type: .Event, identifier: event.url.absoluteString)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
