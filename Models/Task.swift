import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var dueDate: Date?
    var createdAt: Date
    var modifiedAt: Date
    
    // 高效能习惯相关属性
    var isProactive: Bool // 是主动圈还是关注圈任务
    var importance: Int // 1-5 重要性等级
    var urgency: Int // 1-5 紧急性等级
    var quadrant: TaskQuadrant { // 基于重要性和紧急性计算象限
        if importance >= 3 && urgency >= 3 {
            return .importantUrgent
        } else if importance >= 3 && urgency < 3 {
            return .importantNotUrgent
        } else if importance < 3 && urgency >= 3 {
            return .notImportantUrgent
        } else {
            return .notImportantNotUrgent
        }
    }
    
    // 关联
    @Relationship(deleteRule: .nullify, inverse: \Goal.relatedTasks)
    var relatedGoal: Goal?
    
    @Relationship(deleteRule: .cascade, inverse: \EmotionRecord.task)
    var emotionRecord: EmotionRecord?
    
    init(id: UUID = UUID(), title: String, description: String = "", isCompleted: Bool = false, dueDate: Date? = nil, isProactive: Bool = true, importance: Int = 3, urgency: Int = 3) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.isProactive = isProactive
        self.importance = importance
        self.urgency = urgency
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

enum TaskQuadrant: Int, Codable {
    case importantUrgent = 1        // 第一象限：重要且紧急
    case importantNotUrgent = 2     // 第二象限：重要不紧急
    case notImportantUrgent = 3     // 第三象限：紧急不重要
    case notImportantNotUrgent = 4  // 第四象限：既不重要也不紧急
    
    var name: String {
        switch self {
        case .importantUrgent: return "重要且紧急"
        case .importantNotUrgent: return "重要不紧急"
        case .notImportantUrgent: return "紧急不重要"
        case .notImportantNotUrgent: return "既不重要也不紧急"
        }
    }
    
    var color: Color {
        switch self {
        case .importantUrgent: return .red
        case .importantNotUrgent: return .blue
        case .notImportantUrgent: return .orange
        case .notImportantNotUrgent: return .gray
        }
    }
} 