import SwiftUI

struct CheckBoxView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var passedTaskItem: TaskItem
    
    var body: some View {
        Image(systemName: passedTaskItem.isCompleted != nil ? "checkmark.circle.fill" : "ircle")
            .foregroundColor(passedTaskItem.isCompleted() ? .green : .secondary)
                .onTapGesture {
                    if !passedTaskItem.isCompleted(){
                        passedTaskItem.completedData = Date()
                        dateHolder.saveContext(viewContext)
                    }
                }
    }
}

#Preview {
    CheckBoxView(passedTaskItem: TaskItem())
}
