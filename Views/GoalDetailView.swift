import SwiftUI
import SwiftData

struct GoalDetailView: View {
    var goal: Goal
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    @State private var showingNewTaskSheet = false
    @State private var showingEditSheet = false
    
    var relatedTasks: [Task] {
        return tasks.filter { $0.relatedGoal?.id == goal.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 目标信息卡
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: goal.area.icon)
                            .foregroundStyle(.blue)
                            .font(.title2)
                        Text(goal.area.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(goal.timeframe.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(goal.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if !goal.description.isEmpty {
                        Text(goal.description)
                            .padding(.top, 4)
                    }
                    
                    if let targetDate = goal.targetDate {
                        HStack {
                            Image(systemName: "calendar")
                            Text("目标日期: \(targetDate, format: .dateTime.day().month().year())")
                        }
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                
                // 关键结果
                if !goal.keyResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("关键结果")
                            .font(.headline)
                        
                        ForEach(goal.keyResults.indices, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.semibold)
                                Text(goal.keyResults[index])
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                }
                
                // 相关任务
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("相关任务")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingNewTaskSheet = true
                        }) {
                            Label("添加任务", systemImage: "plus")
                                .font(.subheadline)
                        }
                    }
                    
                    if relatedTasks.isEmpty {
                        HStack {
                            Spacer()
                            Text("暂无相关任务")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding()
                    } else {
                        ForEach(relatedTasks) { task in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .fontWeight(task.isCompleted ? .regular : .semibold)
                                    
                                    if !task.description.isEmpty {
                                        Text(task.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                                
                                if task.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Text(task.quadrant.name)
                                        .font(.caption)
                                        .padding(4)
                                        .background(task.quadrant.color.opacity(0.2))
                                        .cornerRadius(4)
                                        .foregroundStyle(task.quadrant.color)
                                }
                            }
                            .padding(.vertical, 8)
                            .opacity(task.isCompleted ? 0.7 : 1)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .padding()
        }
        .navigationTitle("目标详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("编辑")
                }
            }
        }
        .sheet(isPresented: $showingNewTaskSheet) {
            NewTaskView(preselectedGoalId: goal.id)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGoalView(goal: goal)
        }
    }
} 