import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProactiveTasksView()
                .tabItem {
                    Label("积极主动", systemImage: "person.fill.checkmark")
                }
                .tag(0)
            
            MissionAndGoalsView()
                .tabItem {
                    Label("以终为始", systemImage: "scope")
                }
                .tag(1)
            
            TaskQuadrantView()
                .tabItem {
                    Label("要事第一", systemImage: "square.grid.2x2")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, Goal.self, LifeMission.self], inMemory: true)
} 