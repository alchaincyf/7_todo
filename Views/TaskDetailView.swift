import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Task
    @State private var showingEditSheet = false
    @State private var showingEmotionSelector = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 任务基本信息
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(task.quadrant.color.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: task.isProactive ? "person.fill.checkmark" : "exclamationmark.circle")
                                    .foregroundStyle(task.quadrant.color)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(task.isProactive ? "影响圈" : "关注圈")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text(task.quadrant.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(task.quadrant.color.opacity(0.1))
                                    .foregroundStyle(task.quadrant.color)
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                            
                            if let dueDate = task.dueDate {
                                VStack(alignment: .trailing) {
                                    Text("截止日期")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(dueDate, format: .dateTime.day().month().year())
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        Text(task.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if !task.description.isEmpty {
                            Text(task.description)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    
                    // 优先级信息
                    VStack(alignment: .leading, spacing: 12) {
                        Text("优先级信息")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("重要性")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    ForEach(1...5, id: \.self) { i in
                                        Circle()
                                            .fill(i <= task.importance ? Color.blue : Color.gray.opacity(0.3))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("紧急性")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    ForEach(1...5, id: \.self) { i in
                                        Circle()
                                            .fill(i <= task.urgency ? Color.orange : Color.gray.opacity(0.3))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    
                    // 关联目标
                    if let goal = task.relatedGoal {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("关联目标")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: goal.area.icon)
                                    .foregroundStyle(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text(goal.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text(goal.area.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(goal.timeframe.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .foregroundStyle(.secondary)
                                    .cornerRadius(4)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                    
                    // 情绪记录
                    if let emotion = task.emotionRecord {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("完成情绪")
                                .font(.headline)
                            
                            HStack {
                                Text(emotion.emotionType.icon)
                                    .font(.system(size: 40))
                                
                                VStack(alignment: .leading) {
                                    Text(emotion.emotionType.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    if let note = emotion.note {
                                        Text(note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Text("记录于: \(emotion.recordedAt, format: .dateTime)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                    
                    // AI建议
                    if !task.isCompleted {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI助手建议")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(.yellow)
                                    Text("任务优先级分析")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                Text(aiPriorityRecommendation)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("任务详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Text("编辑")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    if !task.isCompleted {
                        Button(action: {
                            showingEmotionSelector = true
                        }) {
                            Text("标记为完成")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Text("任务已完成")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundStyle(.secondary)
                            .cornerRadius(10)
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditTaskView(task: task)
            }
            .sheet(isPresented: $showingEmotionSelector) {
                EmotionSelectorView(task: task, onComplete: { task, emotion in
                    task.isCompleted = true
                    task.modifiedAt = Date()
                    
                    let emotionRecord = EmotionRecord(emotionType: emotion.0, note: emotion.1, task: task)
                    modelContext.insert(emotionRecord)
                    
                    dismiss()
                })
            }
        }
    }
    
    private var aiPriorityRecommendation: String {
        if task.quadrant == .importantUrgent {
            return "这是一个重要且紧急的任务，建议尽快完成。考虑分配专注时间块立即处理。未来可思考如何提前规划类似任务，避免紧急状态。"
        } else if task.quadrant == .importantNotUrgent {
            return "这是一个重要但不紧急的任务，这类任务是个人发展和目标达成的关键。建议在精力充沛时段安排时间块，避免拖延至紧急状态。"
        } else if task.quadrant == .notImportantUrgent {
            return "这是一个紧急但不重要的任务。考虑是否可以委派他人处理，或简化流程。反思是否有系统性问题导致这类任务频繁出现。"
        } else {
            return "这是一个既不重要也不紧急的任务。评估是否有必要完成，或可以被删除。如需完成，安排在精力较低或琐碎时间段处理。"
        }
    }
} 