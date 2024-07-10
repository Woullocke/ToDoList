import SwiftUI

struct TaskEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder

    @State var selectedTaskItem: TaskItem?
    @State var name: String
    @State var desc: String
    @State var dueDate: Date
    @State var scheduleTime: Bool
    
    init(passedTaskItem: TaskItem?, initialDate: Date) {
        if let taskItem = passedTaskItem {
            _selectedTaskItem = State(initialValue: taskItem)
            _name = State(initialValue: taskItem.name ?? "")
            _desc = State(initialValue: taskItem.desc ?? "")
            _dueDate = State(initialValue: taskItem.dueDate ?? initialDate)
            _scheduleTime = State(initialValue: taskItem.scheduleTime)
        } else {
            _name = State(initialValue: "")
            _desc = State(initialValue: "")
            _dueDate = State(initialValue: initialDate)
            _scheduleTime = State(initialValue: false)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Task")) {
                TextField("Task Name", text: $name)
                TextEditorWithPlaceholder(text: $desc, placeholder: "Desc")
                    .frame(height: 100)
            }
            Section(header: Text("Due Date")) {
                Toggle("Schedule Time", isOn: $scheduleTime)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: displayComps())
            }
            if selectedTaskItem?.isCompleted() ?? false {
                Section(header: Text("Completed")) {
                    Text(selectedTaskItem?.completedData?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .foregroundColor(.green)
                }
            }
            Section() {
                Button("Save", action: saveAction)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    func displayComps() -> DatePickerComponents {
        return scheduleTime ? [.hourAndMinute, .date] : [.date]
    }
    
    func saveAction() {
        withAnimation {
            if let selectedTask = selectedTaskItem {
                dateHolder.removeNotification(for: selectedTask)
            } else {
                selectedTaskItem = TaskItem(context: viewContext)
            }
            
            selectedTaskItem?.created = Date()
            selectedTaskItem?.name = name
            selectedTaskItem?.desc = desc
            selectedTaskItem?.dueDate = dueDate
            selectedTaskItem?.scheduleTime = scheduleTime
            
            dateHolder.saveContext(viewContext)
            
            if let task = selectedTaskItem {
                dateHolder.scheduleNotification(for: task)
            }
            
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.placeholderText))
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
            TextEditor(text: $text)
                .padding(4)
        }
    }
}

#Preview {
    TaskEditView(passedTaskItem: nil, initialDate: Date())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(DateHolder(PersistenceController.preview.container.viewContext))
}
