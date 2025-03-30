import Foundation
import SwiftData

@Model
final class LifeMission {
    var id: UUID
    var content: String
    var createdAt: Date
    var lastReviewedAt: Date?
    var visualTheme: String // 存储主题选择
    
    // 关联
    @Relationship(deleteRule: .nullify, inverse: \Goal.mission)
    var relatedGoals: [Goal]?
    
    init(id: UUID = UUID(), content: String, visualTheme: String = "default") {
        self.id = id
        self.content = content
        self.createdAt = Date()
        self.visualTheme = visualTheme
        self.relatedGoals = []
    }
} 