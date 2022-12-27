import SwiftUI

@main
struct todolistApp: App {
    
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
        }.commands {
            SidebarCommands()
        }
    }
}
