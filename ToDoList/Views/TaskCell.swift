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
        Text(passedTaskItem.name ?? "")
            .padding(.horizontal)
    }
}

#Preview {
    TaskCell(passedTaskItem: TaskItem())
}
