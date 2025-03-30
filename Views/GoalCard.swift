import SwiftUI

struct GoalCard: View {
    var goal: Goal
    
    var body: some View {
        NavigationLink(destination: GoalDetailView(goal: goal)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(goal.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(goal.timeframe.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                
                if !goal.description.isEmpty {
                    Text(goal.description)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                }
                
                if let targetDate = goal.targetDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Text("目标日期: \(targetDate, format: .dateTime.day().month().year())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 进度指示器
                if let tasks = goal.relatedTasks, !tasks.isEmpty {
                    let completedCount = tasks.filter { $0.isCompleted }.count
                    let progress = Double(completedCount) / Double(tasks.count)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("进度: \(Int(progress * 100))%")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("\(completedCount)/\(tasks.count) 任务")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        ProgressView(value: progress)
                            .tint(Color.blue)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
} 