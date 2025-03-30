import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var goals: [Goal]
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date().addingTimeInterval(86400) // 默认是明天
    @State private var isProactive: Bool = true
    @State private var importance: Double = 3
    @State private var urgency: Double = 3
    @State private var selectedGoalId: UUID?
    @State private var showingPassiveAlert = false
    @State private var improvedTitle: String = ""
    
    init(preselectedGoalId: UUID? = nil) {
        _selectedGoalId = State(initialValue: preselectedGoalId)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("任务信息")) {
                    TextField("任务标题", text: $title)
                        .onChange(of: title) { _, newValue in
                            analyzeTaskTitle(newValue)
                        }
                    
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
                    
                    if !isProactive {
                        HStack {
                            Image(systemName: "lightbulb")
                                .foregroundStyle(.yellow)
                            Text("关注圈任务是你关心但不能直接控制的事物。考虑是否有相关的影响圈行动？")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
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
            .navigationTitle("新建任务")
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
            .alert("更积极的表述", isPresented: $showingPassiveAlert) {
                Button("采用建议") {
                    title = improvedTitle
                }
                Button("保持原样", role: .cancel) { }
            } message: {
                Text("检测到被动表述，建议更改为：\n\n\"\(improvedTitle)\"")
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
    
    private func analyzeTaskTitle(_ title: String) {
        // 简单的本地被动表述分析
        let passivePatterns = [
            "应该": "我将",
            "需要": "我要",
            "必须": "我决定",
            "希望能": "我将",
            "可能要": "我计划",
            "要求": "我负责"
        ]
        
        for (passive, active) in passivePatterns {
            if title.contains(passive) {
                improvedTitle = title.replacingOccurrences(of: passive, with: active)
                showingPassiveAlert = true
                return
            }
        }
    }
    
    private func saveTask() {
        let newTask = Task(
            title: title,
            description: description,
            dueDate: dueDate,
            isProactive: isProactive,
            importance: Int(importance),
            urgency: Int(urgency)
        )
        
        if let goalId = selectedGoalId, let goal = goals.first(where: { $0.id == goalId }) {
            newTask.relatedGoal = goal
        }
        
        modelContext.insert(newTask)
        dismiss()
    }
} 