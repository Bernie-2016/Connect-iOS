import Foundation


public protocol ConnectItemRepository {
    func fetchConnectItems(completion:(Array<ConnectItem>) -> Void, error:(NSError) -> Void)
}