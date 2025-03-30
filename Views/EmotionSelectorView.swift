import SwiftUI

struct EmotionSelectorView: View {
    var task: Task
    var onComplete: (Task, (EmotionType, String?)) -> Void
    
    @State private var selectedEmotion: EmotionType = .satisfied
    @State private var note: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("恭喜完成任务！")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("记录一下你的感受吧")
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                    ForEach(EmotionType.allCases, id: \.self) { emotion in
                        VStack {
                            Text(emotion.icon)
                                .font(.system(size: 40))
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(selectedEmotion == emotion ? Color.blue.opacity(0.2) : Color.clear)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(selectedEmotion == emotion ? Color.blue : Color.clear, lineWidth: 2)
                                )
                            
                            Text(emotion.rawValue)
                                .font(.caption)
                                .foregroundStyle(selectedEmotion == emotion ? .primary : .secondary)
                        }
                        .onTapGesture {
                            selectedEmotion = emotion
                        }
                    }
                }
                .padding()
                
                TextField("添加笔记（可选）", text: $note, axis: .vertical)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .lineLimit(3...5)
                
                Spacer()
                
                Button(action: {
                    onComplete(task, (selectedEmotion, note.isEmpty ? nil : note))
                    dismiss()
                }) {
                    Text("保存")
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
            .navigationTitle("情绪记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("跳过") {
                        dismiss()
                    }
                }
            }
        }
    }
} 