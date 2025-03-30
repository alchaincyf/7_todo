import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var title: String
    var description: String
    var area: LifeArea // 生活领域
    var timeframe: GoalTimeframe // 时间框架
    var createdAt: Date
    var targetDate: Date?
    var isCompleted: Bool
    var keyResults: [String] // 关键结果/衡量标准
    
    // 关联
    @Relationship(deleteRule: .nullify, inverse: \LifeMission.relatedGoals)
    var mission: LifeMission?
    
    @Relationship(deleteRule: .nullify, inverse: \Task.relatedGoal)
    var relatedTasks: [Task]?
    
    init(id: UUID = UUID(), title: String, description: String = "", area: LifeArea, timeframe: GoalTimeframe, targetDate: Date? = nil, isCompleted: Bool = false, keyResults: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.area = area
        self.timeframe = timeframe
        self.createdAt = Date()
        self.targetDate = targetDate
        self.isCompleted = isCompleted
        self.keyResults = keyResults
        self.relatedTasks = []
    }
}

enum LifeArea: String, CaseIterable, Codable {
    case career = "事业/工作"
    case family = "家庭"
    case health = "健康"
    case learning = "学习"
    case finance = "财务"
    case social = "社交"
    case spiritual = "精神"
    
    var icon: String {
        switch self {
        case .career: return "briefcase"
        case .family: return "house"
        case .health: return "heart"
        case .learning: return "book"
        case .finance: return "dollarsign.circle"
        case .social: return "person.2"
        case .spiritual: return "sparkles"
        }
    }
}

enum GoalTimeframe: String, CaseIterable, Codable {
    case shortTerm = "短期(1个月)"
    case mediumTerm = "中期(1年)"
    case longTerm = "长期(3-5年)"
} 