import SwiftUI
import UserNotifications

@main
struct ToDoListApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            let context = persistenceController.container.viewContext
            let dateHolder = DateHolder(context)
            
            TaskListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dateHolder)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Failed to request authorization: \(error)")
                return
            }
            print("Notification permission granted: \(granted)")
        }
    }
}
