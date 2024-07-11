import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    
    @State var selectedFilter = TaskFilter.NonCompleted

    var body: some View {
        NavigationView {
            VStack{
                DataScroller()
                    .padding()
                    .environmentObject(dateHolder)
                ZStack {
                    List {
                        ForEach(filteredTaskItems()) { taskItem in
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
                                Picker("", selection: $selectedFilter.animation()) {
                                    ForEach(TaskFilter.allFilters, id: \.self) {
                                        filter in
                                        Text(filter.rawValue)
                                    }
                                }
                            }
                        }
                    
                    FloatingButton()
                }
                .navigationTitle("To Do List")
            }
        }
    }
    
    private func filteredTaskItems() -> [TaskItem]
    {
        if selectedFilter == TaskFilter.Completed
        {
            return dateHolder.taskItems.filter{ $0.isCompleted()}
        }
        
        if selectedFilter == TaskFilter.NonCompleted
        {
            return dateHolder.taskItems.filter{ !$0.isCompleted()}
        }
        
        if selectedFilter == TaskFilter.OverDue
        {
            return dateHolder.taskItems.filter{ $0.isOverdue()}
        }
        
        return dateHolder.taskItems
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredTaskItems()[$0] }.forEach(viewContext.delete)

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
