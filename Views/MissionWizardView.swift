import SwiftUI
import SwiftData

struct MissionWizardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var existingMission: LifeMission?
    
    @State private var currentStep = 0
    @State private var answers: [String] = Array(repeating: "", count: 5)
    @State private var finalMissionContent: String = ""
    @State private var selectedTheme: String = "default"
    
    let questions = [
        "你认为生活中最重要的价值是什么？",
        "你希望他人如何记住你？",
        "你对家人、朋友和社会的责任是什么？",
        "你的天赋和热情在哪些方面？",
        "你希望实现什么样的终极目标？"
    ]
    
    let themes = ["default", "nature", "ocean", "mountain", "minimal"]
    
    var body: some View {
        NavigationStack {
            VStack {
                if currentStep < questions.count {
                    // 问题回答阶段
                    questionView
                } else if currentStep == questions.count {
                    // 使命宣言生成和编辑阶段
                    missionEditView
                } else {
                    // 主题选择阶段
                    themeSelectionView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                if currentStep == questions.count + 1 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") {
                            saveMission()
                        }
                        .disabled(finalMissionContent.isEmpty)
                    }
                }
            }
        }
    }
    
    private var navigationTitle: String {
        if currentStep < questions.count {
            return "第 \(currentStep + 1)/\(questions.count) 步"
        } else if currentStep == questions.count {
            return "编辑使命宣言"
        } else {
            return "选择主题"
        }
    }
    
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(questions[currentStep])
                .font(.title3)
                .fontWeight(.semibold)
            
            TextEditor(text: $answers[currentStep])
                .frame(minHeight: 150)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            if !answers[currentStep].isEmpty {
                // AI反馈区域
                VStack(alignment: .leading, spacing: 8) {
                    Text("思考提示")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    Text(getAIFeedback(for: currentStep, answer: answers[currentStep]))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.05))
                )
            }
            
            Spacer()
            
            HStack {
                if currentStep > 0 {
                    Button(action: {
                        currentStep -= 1
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("上一步")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundStyle(.primary)
                        .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    currentStep += 1
                    
                    if currentStep == questions.count {
                        generateMissionStatement()
                    }
                }) {
                    HStack {
                        Text(currentStep == questions.count - 1 ? "生成使命宣言" : "下一步")
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
                .disabled(answers[currentStep].isEmpty)
            }
        }
        .padding()
    }
    
    private var missionEditView: some View {
        VStack(spacing: 20) {
            Text("这是基于你的回答生成的使命宣言草稿。你可以按照自己的想法编辑它。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextEditor(text: $finalMissionContent)
                .frame(minHeight: 200)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            
            Button(action: {
                currentStep += 1
            }) {
                HStack {
                    Text("继续")
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
            .disabled(finalMissionContent.isEmpty)
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var themeSelectionView: some View {
        VStack(spacing: 20) {
            Text("为你的使命宣言选择一个视觉主题")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(themes, id: \.self) { theme in
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeColor(for: theme))
                                .frame(width: 120, height: 160)
                                .overlay(
                                    Text(finalMissionContent)
                                        .font(.caption)
                                        .padding(8)
                                        .lineLimit(6)
                                        .foregroundStyle(themeTextColor(for: theme))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedTheme == theme ? Color.blue : Color.clear, lineWidth: 3)
                                )
                            
                            Text(themeDisplayName(for: theme))
                                .font(.caption)
                                .foregroundStyle(selectedTheme == theme ? .primary : .secondary)
                        }
                        .onTapGesture {
                            selectedTheme = theme
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                saveMission()
            }) {
                Text("完成")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func getAIFeedback(for questionIndex: Int, answer: String) -> String {
        // 简单的本地反馈实现
        let feedbacks = [
            "思考你的核心价值观如何指导你的日常决策？试着列出3-5个最重要的价值观。",
            "想象你的葬礼上，朋友和家人会说些什么？这反映了你对他人的影响。",
            "考虑你在不同角色中的责任：作为家人、朋友、同事和公民。",
            "你在什么活动中感到时间飞逝？这些活动反映了你的自然才能和热情。",
            "如果你有无限的资源和时间，你会如何改变世界或自己的生活？"
        ]
        
        return feedbacks[questionIndex]
    }
    
    private func generateMissionStatement() {
        // 本地生成使命宣言的逻辑
        var mission = "我的使命是根据以下价值观生活：\(answers[0])。\n\n"
        mission += "我希望被记住为：\(answers[1])。\n\n"
        mission += "对家人、朋友和社会，我承担责任：\(answers[2])。\n\n"
        mission += "我将利用我的天赋和热情：\(answers[3])。\n\n"
        mission += "我的终极目标是：\(answers[4])。"
        
        // 如果已有使命宣言，使用其内容作为起点
        if let existingMission = existingMission {
            finalMissionContent = existingMission.content
        } else {
            finalMissionContent = mission
        }
    }
    
    private func themeColor(for theme: String) -> Color {
        switch theme {
        case "nature": return Color.green.opacity(0.2)
        case "ocean": return Color.blue.opacity(0.2)
        case "mountain": return Color.purple.opacity(0.2)
        case "minimal": return Color.gray.opacity(0.1)
        default: return Color.white
        }
    }
    
    private func themeTextColor(for theme: String) -> Color {
        switch theme {
        case "nature": return .green
        case "ocean": return .blue
        case "mountain": return .purple
        case "minimal": return .black
        default: return .primary
        }
    }
    
    private func themeDisplayName(for theme: String) -> String {
        switch theme {
        case "default": return "默认"
        case "nature": return "自然"
        case "ocean": return "海洋"
        case "mountain": return "山峰"
        case "minimal": return "简约"
        default: return theme
        }
    }
    
    private func saveMission() {
        if let existingMission = existingMission {
            // 更新现有使命宣言
            existingMission.content = finalMissionContent
            existingMission.visualTheme = selectedTheme
        } else {
            // 创建新的使命宣言
            let newMission = LifeMission(content: finalMissionContent, visualTheme: selectedTheme)
            modelContext.insert(newMission)
        }
        
        dismiss()
    }
} 