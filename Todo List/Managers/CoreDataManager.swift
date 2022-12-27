import Foundation
import CoreData

class CoreDataManager {
    let persistentContainer: NSPersistentContainer
    static let shared: CoreDataManager = CoreDataManager()
    private init() {
        persistentContainer = NSPersistentContainer(name: "SimpleTodoModel")
        persistentContainer.loadPersistentStores {description, error in
            if let error = error {
                fatalError("Unable to create Core Data \(error)")
            }
        }
    }
}
