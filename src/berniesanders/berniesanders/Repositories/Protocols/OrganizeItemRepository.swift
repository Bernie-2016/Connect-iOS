import Foundation


public protocol OrganizeItemRepository {
    func fetchOrganizeItems(completion:(Array<OrganizeItem>) -> Void, error:(NSError) -> Void)
}