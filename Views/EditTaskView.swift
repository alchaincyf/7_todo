import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Bindable var task: Task
    
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var isProactive: Bool
    @State private var importance: Double
    @State private var urgency: Double
    @State private var selectedGoalId: UUID?
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _dueDate = State(initialValue: task.dueDate ?? Date().addingTimeInterval(86400))
        _isProactive = State(initialValue: task.isProactive)
        _importance = State(initialValue: Double(task.importance))
        _urgency = State(initialValue: Double(task.urgency))
        _selectedGoalId = State(initialValue: task.relatedGoal?.id)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("任务信息")) {
                    TextField("任务标题", text: $title)
                    
                    TextField("任务描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("截止日期", selection: $dueDate, displayedComponents: [.date])
                }
                
                Section(header: Text("任务分类")) {
                    Picker("任务类型", selection: $isProactive) {
                        Text("影响圈").tag(true)
                        Text("关注圈").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("任务优先级")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("重要性: \(Int(importance))")
                            Spacer()
                            Text(importanceLabel)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $importance, in: 1...5, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("紧急性: \(Int(urgency))")
                            Spacer()
                            Text(urgencyLabel)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $urgency, in: 1...5, step: 1)
                    }
                    
                    HStack {
                        Text("任务象限:")
                        Spacer()
                        Text(quadrantText)
                            .foregroundStyle(quadrantColor)
                            .fontWeight(.semibold)
                    }
                }
                
                if !goals.isEmpty {
                    Section(header: Text("关联目标")) {
                        Picker("选择关联目标", selection: $selectedGoalId) {
                            Text("无关联目标").tag(Optional<UUID>(nil))
                            ForEach(goals) { goal in
                                Text(goal.title).tag(Optional(goal.id))
                            }
                        }
                    }
                }
            }
            .navigationTitle("编辑任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private var importanceLabel: String {
        switch Int(importance) {
        case 1: return "很低"
        case 2: return "较低"
        case 3: return "中等"
        case 4: return "较高"
        case 5: return "很高"
        default: return ""
        }
    }
    
    private var urgencyLabel: String {
        switch Int(urgency) {
        case 1: return "不急"
        case 2: return "较不急"
        case 3: return "一般"
        case 4: return "较急"
        case 5: return "很急"
        default: return ""
        }
    }
    
    private var quadrantText: String {
        if importance >= 3 && urgency >= 3 {
            return "重要且紧急"
        } else if importance >= 3 && urgency < 3 {
            return "重要不紧急"
        } else if importance < 3 && urgency >= 3 {
            return "紧急不重要"
        } else {
            return "既不重要也不紧急"
        }
    }
    
    private var quadrantColor: Color {
        if importance >= 3 && urgency >= 3 {
            return .red
        } else if importance >= 3 && urgency < 3 {
            return .blue
        } else if importance < 3 && urgency >= 3 {
            return .orange
        } else {
            return .gray
        }
    }
    
    private func saveTask() {
        task.title = title
        task.description = description
        task.dueDate = dueDate
        task.isProactive = isProactive
        task.importance = Int(importance)
        task.urgency = Int(urgency)
        task.modifiedAt = Date()
        
        // 更新关联目标
        if let goalId = selectedGoalId, let goal = goals.first(where: { $0.id == goalId }) {
            task.relatedGoal = goal
        } else {
            task.relatedGoal = nil
        }
        
        dismiss()
    }
} 