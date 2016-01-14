class ParseAnalyticsNotificationHandler: UserNotificationHandler {
    let pfAnalyticsProxy: PFAnalyticsProxy

    init(pfAnalyticsProxy: PFAnalyticsProxy) {
        self.pfAnalyticsProxy = pfAnalyticsProxy
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
            pfAnalyticsProxy.trackAppOpenedWithRemoteNotificationPayload(notificationUserInfo)
    }
}
