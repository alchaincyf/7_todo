import SwiftUI
import SwiftData

@main
struct EffectiveHabitsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Task.self, Goal.self, LifeMission.self, EmotionRecord.self])
        }
    }
} 