
import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var reminderTime = Date()
    @State private var showingAbout = false
    @State private var showingFeedback = false
    
    var body: some View {
        NavigationStack {
            List {
                // 通知设置
                Section(header: Text("通知")) {
                    Toggle("启用通知", isOn: $notificationsEnabled)
                    
                    HStack {
                        Text("提醒时间")
                        Spacer()
                        DatePicker(
                            "",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                    }
                    .opacity(notificationsEnabled ? 1.0 : 0.5)
                    .disabled(!notificationsEnabled)
                }
                
                // 显示设置
                Section(header: Text("显示")) {
                    Toggle("深色模式", isOn: $darkModeEnabled)
                }
                
                // 数据管理
                Section(header: Text("数据管理")) {
                    Button("备份数据") {
                        // 备份数据功能
                    }
                    
                    Button("恢复数据") {
                        // 恢复数据功能
                    }
                    
                    Button("导出数据") {
                        // 导出数据功能
                    }
                    .foregroundStyle(.blue)
                }
                
                // 支持
                Section(header: Text("支持")) {
                    Button("帮助与反馈") {
                        showingFeedback = true
                    }
                    
                    Button("关于高效能习惯助手") {
                        showingAbout = true
                    }
                }
                
                // 法律信息
                Section(header: Text("法律信息")) {
                    Button("隐私政策") {
                        // 显示隐私政策
                    }
                    
                    Button("服务条款") {
                        // 显示服务条款
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingFeedback) {
                FeedbackView()
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 8) {
                        Text("高效能习惯助手")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("版本 1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("基于史蒂芬·柯维的《高效能人士的七个习惯》理念，结合前沿AI技术，帮助你培养真正改变生活的习惯。")
                            .multilineTextAlignment(.center)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("功能亮点")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• 积极主动：影响圈 vs 关注圈任务管理")
                                Text("• 以终为始：个人使命宣言和目标设定")
                                Text("• 要事第一：四象限任务管理和时间块规划")
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("致谢")
                                .font(.headline)
                            
                            Text("感谢您使用高效能习惯助手！我们希望这款应用能够帮助您培养真正改变生活的习惯，实现个人和职业上的成功。")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FeedbackView: View {
    @State private var feedbackText = ""
    @State private var feedbackType = FeedbackType.suggestion
    @Environment(\.dismiss) private var dismiss
    
    enum FeedbackType: String, CaseIterable {
        case bug = "问题报告"
        case suggestion = "功能建议"
        case praise = "表扬"
        
        var icon: String {
            switch self {
            case .bug: return "ant"
            case .suggestion: return "lightbulb"
            case .praise: return "hand.thumbsup"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("反馈类型")) {
                        Picker("反馈类型", selection: $feedbackType) {
                            ForEach(FeedbackType.allCases, id: \.self) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue)
                                }
                                .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section(header: Text("反馈内容")) {
                        TextEditor(text: $feedbackText)
                            .frame(height: 150)
                    }
                }
                
                VStack(spacing: 16) {
                    Button("提交反馈") {
                        submitFeedback()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(feedbackText.isEmpty)
                    
                    Text("您的反馈将帮助我们改进应用体验")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("帮助与反馈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submitFeedback() {
        // 提交反馈的逻辑
        print("提交反馈: \(feedbackType.rawValue) - \(feedbackText)")
        
        // 显示提交成功的提示
        // 在实际应用中，这里会发送反馈到服务器
        
        dismiss()
    }
}

#Preview {
    SettingsView()
}
