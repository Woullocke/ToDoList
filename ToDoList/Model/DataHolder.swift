import SwiftUI
import CoreData
import UserNotifications

class DateHolder: ObservableObject {
    @Published var date = Date()
    @Published var taskItems: [TaskItem] = []
    let calendar: Calendar = Calendar.current
    
    func moveDate(_ days: Int,_ context: NSManagedObjectContext) {
        date = calendar.date(byAdding: .day, value: days, to: date)!
        refreshTaskItems(context)
    }

    init(_ context: NSManagedObjectContext) {
        refreshTaskItems(context)
    }
    
    func refreshTaskItems(_ context: NSManagedObjectContext) {
        taskItems = fetchTaskItems(context)
    }
    
    func fetchTaskItems(_ context: NSManagedObjectContext) -> [TaskItem] {
        do {
            return try context.fetch(dailyTasksFetch()) as [TaskItem]
        } catch let error {
            fatalError("Unresolved error \(error)")
        }
    }
    
    func dailyTasksFetch() -> NSFetchRequest<TaskItem> {
        let request = TaskItem.fetchRequest()
        
        request.sortDescriptors = sortOrder()
        request.predicate = predicate()
        return request
    }
    
    private func sortOrder() -> [NSSortDescriptor] {
        let completedDateSort = NSSortDescriptor(keyPath: \TaskItem.completedData, ascending: true)
        let timeSort = NSSortDescriptor(keyPath: \TaskItem.scheduleTime, ascending: true)
        let dueDateSort = NSSortDescriptor(keyPath: \TaskItem.dueDate, ascending: true)

        return [completedDateSort, timeSort, dueDateSort]
    }
    
    private func predicate() -> NSPredicate {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)
        return NSPredicate(format: "dueDate >= %@ AND dueDate < %@", start as NSDate, end! as NSDate)
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            refreshTaskItems(context)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func scheduleNotification(for task: TaskItem) {
        let content = UNMutableNotificationContent()
        content.title = "ToDoList"
        content.body = task.name ?? "No Task Name"
        content.sound = .default

        if let dueDate = task.dueDate {
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let request = UNNotificationRequest(identifier: task.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }

    func removeNotification(for task: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.objectID.uriRepresentation().absoluteString])
    }
}
