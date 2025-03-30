import SwiftUI
import SwiftData

struct NewGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var mission: LifeMission?
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedArea: LifeArea = .career
    @State private var selectedTimeframe: GoalTimeframe = .mediumTerm
    @State private var targetDate: Date = Date().addingTimeInterval(86400 * 30) // 默认一个月后
    @State private var keyResults: [String] = [""]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("目标信息")) {
                    TextField("目标标题", text: $title)
                    
                    TextField("目标描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("目标领域")) {
                    Picker("生活领域", selection: $selectedArea) {
                        ForEach(LifeArea.allCases, id: \.self) { area in
                            Label(area.rawValue, systemImage: area.icon).tag(area)
                        }
                    }
                }
                
                Section(header: Text("时间框架")) {
                    Picker("时间框架", selection: $selectedTimeframe) {
                        ForEach(GoalTimeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("目标日期", selection: $targetDate, displayedComponents: [.date])
                }
                
                Section(header: HStack {
                    Text("关键结果")
                    Spacer()
                    Button(action: {
                        keyResults.append("")
                    }) {
                        Label("添加", systemImage: "plus")
                    }
                }) {
                    ForEach(keyResults.indices, id: \.self) { index in
                        HStack {
                            TextField("关键结果 \(index + 1)", text: $keyResults[index])
                            
                            if keyResults.count > 1 {
                                Button(action: {
                                    keyResults.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("创建新目标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || keyResults.contains(where: { $0.isEmpty }))
                }
            }
        }
    }
    
    private func saveGoal() {
        let filteredKeyResults = keyResults.filter { !$0.isEmpty }
        
        let newGoal = Goal(
            title: title,
            description: description,
            area: selectedArea,
            timeframe: selectedTimeframe,
            targetDate: targetDate,
            keyResults: filteredKeyResults
        )
        
        if let mission = mission {
            newGoal.mission = mission
        }
        
        modelContext.insert(newGoal)
        dismiss()
    }
} 