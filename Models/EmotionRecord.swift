import Foundation
import SwiftData

@Model
final class EmotionRecord {
    var id: UUID
    var emotionType: EmotionType
    var note: String?
    var recordedAt: Date
    
    // 关联
    @Relationship(deleteRule: .nullify, inverse: \Task.emotionRecord)
    var task: Task?
    
    init(id: UUID = UUID(), emotionType: EmotionType, note: String? = nil, task: Task? = nil) {
        self.id = id
        self.emotionType = emotionType
        self.note = note
        self.recordedAt = Date()
        self.task = task
    }
}

enum EmotionType: String, CaseIterable, Codable {
    case happy = "高兴"
    case satisfied = "满足"
    case calm = "平静"
    case tired = "疲惫"
    case frustrated = "沮丧"
    case anxious = "焦虑"
    case motivated = "动力满满"
    
    var icon: String {
        switch self {
        case .happy: return "😄"
        case .satisfied: return "😊"
        case .calm: return "😌"
        case .tired: return "😩"
        case .frustrated: return "😞"
        case .anxious: return "😰"
        case .motivated: return "💪"
        }
    }
    
    var isPositive: Bool {
        switch self {
        case .happy, .satisfied, .calm, .motivated:
            return true
        case .tired, .frustrated, .anxious:
            return false
        }
    }
} 