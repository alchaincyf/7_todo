import SwiftUI
import SwiftData

struct ProactiveTasksView: View {
    @Query private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewTaskSheet = false
    @State private var selectedTask: Task?
    @State private var showingEmotionSelector = false
    
    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("我的影响圈").font(.headline)) {
                    ForEach(tasks.filter { $0.isProactive && !$0.isCompleted }) { task in
                        TaskRow(task: task, onComplete: {
                            selectedTask = task
                            showingEmotionSelector = true
                        })
                    }
                    .onDelete { indexSet in
                        deleteProactiveTasks(at: indexSet)
                    }
                }
                
                Section(header: Text("我的关注圈").font(.headline)) {
                    ForEach(tasks.filter { !$0.isProactive && !$0.isCompleted }) { task in
                        TaskRow(task: task, onComplete: {
                            selectedTask = task
                            showingEmotionSelector = true
                        })
                    }
                    .onDelete { indexSet in
                        deleteConcernTasks(at: indexSet)
                    }
                }
            }
            .navigationTitle("积极主动")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewTaskSheet = true
                    }) {
                        Label("新建任务", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskView()
            }
            .sheet(isPresented: $showingEmotionSelector) {
                if let task = selectedTask {
                    EmotionSelectorView(task: task, onComplete: { task, emotion in
                        task.isCompleted = true
                        task.modifiedAt = Date()
                        
                        let emotionRecord = EmotionRecord(emotionType: emotion.0, note: emotion.1, task: task)
                        modelContext.insert(emotionRecord)
                        
                        selectedTask = nil
                    })
                }
            }
        } detail: {
            Text("选择一个任务查看详情")
                .foregroundStyle(.secondary)
        }
    }
    
    private func deleteProactiveTasks(at offsets: IndexSet) {
        let tasksToDelete = offsets.map { tasks.filter { $0.isProactive && !$0.isCompleted }[$0] }
        for task in tasksToDelete {
            modelContext.delete(task)
        }
    }
    
    private func deleteConcernTasks(at offsets: IndexSet) {
        let tasksToDelete = offsets.map { tasks.filter { !$0.isProactive && !$0.isCompleted }[$0] }
        for task in tasksToDelete {
            modelContext.delete(task)
        }
    }
}

struct TaskRow: View {
    var task: Task
    var onComplete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
                
                if let dueDate = task.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                        Text(dueDate, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onComplete) {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(Color.green)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
} 