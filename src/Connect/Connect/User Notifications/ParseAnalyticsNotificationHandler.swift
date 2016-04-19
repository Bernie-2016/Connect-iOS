class ParseAnalyticsNotificationHandler: RemoteNotificationHandler {
    let pfAnalyticsProxy: PFAnalyticsProxy

    init(pfAnalyticsProxy: PFAnalyticsProxy) {
        self.pfAnalyticsProxy = pfAnalyticsProxy
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo, fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        pfAnalyticsProxy.trackAppOpenedWithRemoteNotificationPayload(notificationUserInfo)
    }
}
