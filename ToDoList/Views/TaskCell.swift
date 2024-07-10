//
//  TaskCell.swift
//  ToDoList
//
//  Created by Иван Булгаков on 8.7.2024.
//

import SwiftUI

struct TaskCell: View {
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var passedTaskItem: TaskItem

    var body: some View {
        CheckBoxView(passedTaskItem: passedTaskItem)
            .environmentObject(dateHolder)
        
        Text(passedTaskItem.name ?? "")
            .padding(.horizontal)

        if !passedTaskItem.isCompleted() && passedTaskItem.scheduleTime {
            Text(passedTaskItem.dueDateTimeOnly())
                .font(.footnote)
                .foregroundColor(passedTaskItem.overDueColor())
                .padding(.horizontal)
        }
    }
}

#Preview {
    TaskCell(passedTaskItem: TaskItem())
}
