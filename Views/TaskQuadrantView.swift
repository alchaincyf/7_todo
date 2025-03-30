import SwiftUI
import SwiftData

struct TaskQuadrantView: View {
    @Query(filter: #Predicate<Task> { !$0.isCompleted }) private var activeTasks: [Task]
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewTaskSheet = false
    @State private var selectedTask: Task?
    @State private var showingTaskDetail = false
    @State private var showingTimeBlockView = false
    @State private var draggedTask: Task?
    @State private var draggedQuadrant: TaskQuadrant?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 象限头部标签
                HStack(spacing: 0) {
                    Text("紧急")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                    
                    Text("不紧急")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // 侧边标签 + 网格
                HStack(spacing: 0) {
                    // 左侧标签
                    VStack(spacing: 0) {
                        Text("重要")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxHeight: .infinity)
                            .rotationEffect(Angle(degrees: -90))
                            .foregroundStyle(.secondary)
                        
                        Text("不重要")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxHeight: .infinity)
                            .rotationEffect(Angle(degrees: -90))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 20)
                    
                    // 四象限网格
                    VStack(spacing: 1) {
                        HStack(spacing: 1) {
                            // 第一象限：重要且紧急
                            quadrantView(.importantUrgent)
                            
                            // 第二象限：重要不紧急
                            quadrantView(.importantNotUrgent)
                        }
                        
                        HStack(spacing: 1) {
                            // 第三象限：紧急不重要
                            quadrantView(.notImportantUrgent)
                            
                            // 第四象限：既不重要也不紧急
                            quadrantView(.notImportantNotUrgent)
                        }
                    }
                }
            }
            .navigationTitle("要事第一")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewTaskSheet = true
                    }) {
                        Label("新建任务", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingTimeBlockView = true
                    }) {
                        Label("时间块", systemImage: "clock")
                    }
                }
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskView()
            }
            .sheet(isPresented: $showingTaskDetail) {
                if let selectedTask = selectedTask {
                    TaskDetailView(task: selectedTask)
                }
            }
            .sheet(isPresented: $showingTimeBlockView) {
                TimeBlockView()
            }
        }
    }
    
    private func quadrantView(_ quadrant: TaskQuadrant) -> some View {
        let quadrantTasks = activeTasks.filter { $0.quadrant == quadrant }
        
        return ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(quadrant.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(quadrant.color.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 0) {
                // 象限标题
                HStack {
                    Text(quadrant.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(quadrant.color)
                    
                    Spacer()
                    
                    Text("\(quadrantTasks.count)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(quadrant.color.opacity(0.2))
                        )
                        .foregroundStyle(quadrant.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                
                // 任务列表
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(quadrantTasks) { task in
                            TaskQuadrantCard(task: task)
                                .onTapGesture {
                                    selectedTask = task
                                    showingTaskDetail = true
                                }
                                .onDrag {
                                    self.draggedTask = task
                                    self.draggedQuadrant = quadrant
                                    return NSItemProvider(object: task.id.uuidString as NSString)
                                }
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.vertical, 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onDrop(of: ["public.text"], isTargeted: nil) { providers, _ in
            guard let draggedTask = self.draggedTask,
                  let draggedQuadrant = self.draggedQuadrant,
                  draggedQuadrant != quadrant else {
                return false
            }
            
            // 更新拖放的任务象限
            updateTaskQuadrant(task: draggedTask, toQuadrant: quadrant)
            
            // 清除拖放状态
            self.draggedTask = nil
            self.draggedQuadrant = nil
            
            return true
        }
    }
    
    private func updateTaskQuadrant(task: Task, toQuadrant quadrant: TaskQuadrant) {
        // 根据目标象限设置重要性和紧急性
        switch quadrant {
        case .importantUrgent:
            task.importance = 4
            task.urgency = 4
        case .importantNotUrgent:
            task.importance = 4
            task.urgency = 2
        case .notImportantUrgent:
            task.importance = 2
            task.urgency = 4
        case .notImportantNotUrgent:
            task.importance = 2
            task.urgency = 2
        }
        
        task.modifiedAt = Date()
    }
}

struct TaskQuadrantCard: View {
    var task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            if let dueDate = task.dueDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(dueDate, style: .date)
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
            
            if let goal = task.relatedGoal {
                HStack {
                    Image(systemName: "scope")
                        .font(.caption2)
                    Text(goal.title)
                        .font(.caption2)
                        .lineLimit(1)
                }
                .foregroundStyle(.blue)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
} 