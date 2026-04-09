import SwiftUI
import FoundationModels

struct PromptBuilderView: View {
    @State private var basePrompt = "推荐一个旅行目的地"
    @State private var includeBudget = false
    @State private var budget = "5000"
    @State private var includeSeason = false
    @State private var season = "夏天"
    @State private var includeStyle = false
    @State private var travelStyle = "冒险"
    @State private var includePeople = false
    @State private var people = "2"

    @State private var responseText = ""
    @State private var isGenerating = false
    @State private var error: String?

    private let seasons = ["春天", "夏天", "秋天", "冬天"]
    private let styles = ["冒险", "休闲", "文化探索", "美食之旅", "自然风光"]

    var body: some View {
        Form {
            Section("基础提示词") {
                TextField("基本需求...", text: $basePrompt, axis: .vertical)
                    .lineLimit(1...3)
            }

            Section("动态条件 (@PromptBuilder)") {
                Toggle("包含预算", isOn: $includeBudget)
                if includeBudget {
                    TextField("预算 (元)", text: $budget)
                        .keyboardType(.numberPad)
                }

                Toggle("指定季节", isOn: $includeSeason)
                if includeSeason {
                    Picker("季节", selection: $season) {
                        ForEach(seasons, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Toggle("旅行风格", isOn: $includeStyle)
                if includeStyle {
                    Picker("风格", selection: $travelStyle) {
                        ForEach(styles, id: \.self) { Text($0) }
                    }
                }

                Toggle("出行人数", isOn: $includePeople)
                if includePeople {
                    TextField("人数", text: $people)
                        .keyboardType(.numberPad)
                }
            }

            Section("Prompt 预览") {
                Text(promptPreview)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("使用 @PromptBuilder 生成") {
                    generate()
                }
                .disabled(basePrompt.isEmpty || isGenerating)
            }

            if isGenerating {
                Section {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("生成中...")
                    }
                }
            }

            if let error {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }

            if !responseText.isEmpty {
                Section("响应") {
                    Text(responseText)
                        .textSelection(.enabled)
                }
            }

            Section("API 说明") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("try await session.respond {")
                    Text("    basePrompt")
                    Text("    if showBudget {")
                    Text("        \"预算是 \\(budget) 元\"")
                    Text("    }")
                    Text("    if showSeason { ... }")
                    Text("}")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var promptPreview: String {
        var lines = [basePrompt]
        if includeBudget { lines.append("+ 预算: \(budget) 元") }
        if includeSeason { lines.append("+ 季节: \(season)") }
        if includeStyle { lines.append("+ 风格: \(travelStyle)") }
        if includePeople { lines.append("+ 人数: \(people) 人") }
        return lines.joined(separator: "\n")
    }

    private func generate() {
        isGenerating = true
        responseText = ""
        error = nil

        // Capture current values for the builder closure
        let base = basePrompt
        let showBudget = includeBudget
        let budgetVal = budget
        let showSeason = includeSeason
        let seasonVal = season
        let showStyle = includeStyle
        let styleVal = travelStyle
        let showPeople = includePeople
        let peopleVal = people

        Task {
            do {
                let session = LanguageModelSession(
                    instructions: Instructions("你是一个专业的旅行规划师。根据用户的各项需求给出详细的旅行推荐。")
                )
                let response = try await session.respond {
                    base
                    if showBudget {
                        "我的预算大约是 \(budgetVal) 元"
                    }
                    if showSeason {
                        "我计划在\(seasonVal)出行"
                    }
                    if showStyle {
                        "我偏好\(styleVal)类型的旅行"
                    }
                    if showPeople {
                        "一共 \(peopleVal) 个人出行"
                    }
                }
                responseText = response.content
            } catch {
                self.error = error.localizedDescription
            }
            isGenerating = false
        }
    }
}
