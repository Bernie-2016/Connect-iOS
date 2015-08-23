import Foundation


class ConcreteOrganizeItemRepository : OrganizeItemRepository {
    func fetchOrganizeItems(completion: (Array<OrganizeItem>) -> Void, error: (NSError) -> Void) {
        var organizeItemA = OrganizeItem(title: "Millenium Barn Dance featuring Jet from Gladiators", date: NSDate())
        var organizeItemB = OrganizeItem(title: "A Partridge Amongst The Pigeons", date: NSDate())
        
        completion([organizeItemA, organizeItemB])
    }
}