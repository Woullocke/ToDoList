import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.dueDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<TaskItem>

    var body: some View {
        NavigationView {
            VStack{
                ZStack {
                    List {
                        ForEach(items) { taskItem in
                            NavigationLink(destination: TaskEditView(passedTaskItem: taskItem, initialDate: Date())
                                .environmentObject(dateHolder)) {
                                    TaskCell(passedTaskItem: taskItem)
                                        .environmentObject(dateHolder)
                                }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                    }
                    FloatingButton()
                }
                .navigationTitle("To Do List")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    TaskListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
