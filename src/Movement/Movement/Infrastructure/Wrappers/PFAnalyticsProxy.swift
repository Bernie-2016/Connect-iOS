import Parse

class PFAnalyticsProxy {
    func trackAppOpenedWithRemoteNotificationPayload(userInfo: NotificationUserInfo) {
        PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    }
}
