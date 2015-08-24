import Foundation


class ConcreteConnectItemRepository : ConnectItemRepository {
    func fetchConnectItems(completion: (Array<ConnectItem>) -> Void, error: (NSError) -> Void) {
        var connectItemA = ConnectItem(title: "House party at Bernie's", date: NSDate())
        var connectItemB = ConnectItem(title: "All night-rave at Bernie's", date: NSDate())
        
        completion([connectItemA, connectItemB])
    }
}