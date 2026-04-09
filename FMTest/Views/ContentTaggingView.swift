import SwiftUI
import FoundationModels

struct ContentTaggingView: View {
    @State private var input = ""
    @State private var result: ContentTags?
    @State private var isGenerating = false
    @State private var error: String?

    private let examples = [
        "今天公司宣布了新的远程办公政策，员工们非常兴奋，纷纷表示这将大大提高工作效率和生活质量。",
        "全球气温持续上升，科学家警告如果不采取紧急行动，未来十年将面临严重的环境危机。",
        "这家新开的咖啡店环境很好，咖啡味道也不错，就是价格稍微贵了一点，总体来说值得一试。",
        "刚学完 SwiftUI 的新教程，感觉收获很大，接下来准备动手做一个完整的项目练练手。",
    ]

    var body: some View {
        Form {
            Section("说明") {
                Text("使用 SystemLanguageModel(useCase: .contentTagging) 对文本进行内容标注，提取主题、情感、关键词等结构化标签。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("示例文本 (点击选择)") {
                ForEach(examples, id: \.self) { example in
                    Button {
                        input = example
                    } label: {
                        Text(example)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                }
            }

            Section("输入文本") {
                TextField("输入要分析的文本...", text: $input, axis: .vertical)
                    .lineLimit(3...8)

                Button("分析内容标签") {
                    analyze()
                }
                .disabled(input.isEmpty || isGenerating)
            }

            if isGenerating {
                Section {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("分析中...")
                    }
                }
            }

            if let error {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }

            if let tags = result {
                Section("分析结果") {
                    LabeledContent("主题") {
                        Text(tags.topic).bold()
                    }

                    LabeledContent("情感") {
                        Text(tags.emotion)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(emotionColor(tags.emotion).opacity(0.2))
                            .foregroundStyle(emotionColor(tags.emotion))
                            .clipShape(Capsule())
                    }

                    LabeledContent("类别") {
                        Text(tags.category)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    LabeledContent("重要性") {
                        HStack(spacing: 2) {
                            ForEach(0..<10, id: \.self) { i in
                                Circle()
                                    .fill(i < tags.importance ? Color.orange : Color.gray.opacity(0.2))
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                }

                Section("关键词") {
                    FlowLayout(spacing: 8) {
                        ForEach(tags.keywords, id: \.self) { keyword in
                            Text(keyword)
                                .font(.callout)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Section("API 说明") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("let model = SystemLanguageModel(")
                    Text("    useCase: .contentTagging")
                    Text(")")
                    Text("let session = LanguageModelSession(model: model)")
                    Text("let response = try await session.respond(")
                    Text("    to: text, generating: ContentTags.self")
                    Text(")")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private func emotionColor(_ emotion: String) -> Color {
        switch emotion {
        case "开心", "兴奋", "期待": .green
        case "难过", "担忧": .blue
        case "愤怒": .red
        default: .gray
        }
    }

    private func analyze() {
        isGenerating = true
        result = nil
        error = nil

        Task {
            do {
                let model = SystemLanguageModel(useCase: .contentTagging)
                let session = LanguageModelSession(model: model)
                let response = try await session.respond(
                    to: "分析以下文本的内容标签：\(input)",
                    generating: ContentTags.self
                )
                result = response.content
            } catch {
                self.error = error.localizedDescription
            }
            isGenerating = false
        }
    }
}
