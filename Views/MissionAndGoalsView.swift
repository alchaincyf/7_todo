
import SwiftUI
import SwiftData

struct MissionAndGoalsView: View {
    @Query private var missions: [LifeMission]
    @Query private var goals: [Goal]
    @Environment(\.modelContext) private var modelContext
    @State private var showingMissionWizard = false
    @State private var showingNewGoal = false
    @State private var selectedGoal: Goal?
    @State private var showingGoalDetail = false
    
    var currentMission: LifeMission? {
        missions.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 个人使命宣言部分
                    if let mission = currentMission {
                        MissionCardView(mission: mission) {
                            showingMissionWizard = true
                        }
                    } else {
                        EmptyMissionView {
                            showingMissionWizard = true
                        }
                    }
                    
                    // 目标列表部分
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("我的目标")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                showingNewGoal = true
                            }) {
                                Label("添加目标", systemImage: "plus")
                            }
                        }
                        
                        if goals.isEmpty {
                            EmptyGoalsView {
                                showingNewGoal = true
                            }
                        } else {
                            ForEach(LifeArea.allCases, id: \.self) { area in
                                let areaGoals = goals.filter { $0.area == area }
                                if !areaGoals.isEmpty {
                                    Section(header: 
                                        HStack {
                                            Image(systemName: area.icon)
                                            Text(area.rawValue)
                                            Spacer()
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                    ) {
                                        ForEach(areaGoals) { goal in
                                            GoalCard(goal: goal)
                                                .onTapGesture {
                                                    selectedGoal = goal
                                                    showingGoalDetail = true
                                                }
                                        }
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
                }
                .padding()
            }
            .navigationTitle("以终为始")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingMissionWizard = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                    .disabled(currentMission == nil)
                }
            }
            .sheet(isPresented: $showingMissionWizard) {
                MissionWizardView(existingMission: currentMission)
            }
            .sheet(isPresented: $showingNewGoal) {
                NewGoalView()
            }
            .sheet(isPresented: $showingGoalDetail) {
                if let goal = selectedGoal {
                    GoalDetailView(goal: goal)
                }
            }
        }
    }
}

struct MissionCardView: View {
    var mission: LifeMission
    var onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("我的使命宣言")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "square.and.pencil")
                        .font(.body)
                }
            }
            
            Text(mission.content)
                .font(.body)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            
            HStack {
                Text("上次回顾:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let lastReviewed = mission.lastReviewedAt {
                    Text(lastReviewed, style: .date)
                        .font(.caption)
                        .fontWeight(.medium)
                } else {
                    Text("从未")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Button("回顾") {
                    // 更新回顾时间
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct EmptyMissionView: View {
    var onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("尚未创建个人使命宣言")
                    .font(.headline)
                
                Text("个人使命宣言是高效能习惯的核心，它将指导你做出重要决策")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("创建使命宣言") {
                onCreate()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct EmptyGoalsView: View {
    var onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("尚未设定目标")
                    .font(.headline)
                
                Text("设定清晰的目标将帮助你专注于真正重要的事情")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("添加目标") {
                onCreate()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MissionAndGoalsView()
        .modelContainer(for: [LifeMission.self, Goal.self], inMemory: true)
}
