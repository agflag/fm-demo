import SwiftUI
import FoundationModels

struct ToolCallingView: View {
    @State private var prompt = ""
    @State private var responseText = ""
    @State private var isGenerating = false
    @State private var error: String?
    @State private var transcriptText = ""

    private let examplePrompts = [
        "北京今天天气怎么样？",
        "帮我算一下 123.45 乘以 67.89",
        "东京和上海的天气分别怎么样？",
        "如果我有 1000 元，汇率是 0.14，换成美元是多少？",
    ]

    var body: some View {
        Form {
            Section("可用工具") {
                Label {
                    VStack(alignment: .leading) {
                        Text("getWeather").font(.headline)
                        Text("查询城市天气 (模拟数据)").font(.caption).foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "cloud.sun")
                }

                Label {
                    VStack(alignment: .leading) {
                        Text("calculate").font(.headline)
                        Text("四则运算").font(.caption).foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "function")
                }
            }

            Section("示例") {
                ForEach(examplePrompts, id: \.self) { example in
                    Button {
                        prompt = example
                    } label: {
                        Text(example)
                            .foregroundStyle(.primary)
                    }
                }
            }

            Section("输入") {
                TextField("输入需要使用工具的问题...", text: $prompt, axis: .vertical)
                    .lineLimit(2...5)

                Button("发送") {
                    generate()
                }
                .disabled(prompt.isEmpty || isGenerating)
            }

            if isGenerating {
                Section {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("处理中 (可能包含工具调用)...")
                            .foregroundStyle(.secondary)
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
                Section("最终响应") {
                    Text(responseText)
                        .textSelection(.enabled)
                }
            }

            if !transcriptText.isEmpty {
                Section("Transcript 记录 (含工具调用链)") {
                    Text(transcriptText)
                        .font(.system(.caption2, design: .monospaced))
                        .textSelection(.enabled)
                }
            }

            Section("API 说明") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("struct WeatherTool: Tool {")
                    Text("    func call(arguments:) async throws -> String")
                    Text("}")
                    Text("")
                    Text("let session = LanguageModelSession(")
                    Text("    tools: [WeatherTool(), CalculatorTool()]")
                    Text(")")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private func generate() {
        isGenerating = true
        responseText = ""
        transcriptText = ""
        error = nil

        Task {
            do {
                let session = LanguageModelSession(
                    tools: [WeatherTool(), CalculatorTool()],
                    instructions: Instructions("你是一个有帮助的助手。需要时请使用工具获取信息或进行计算。用中文回答。")
                )
                let response = try await session.respond(to: prompt)
                responseText = response.content
                transcriptText = String(describing: session.transcript)
            } catch {
                self.error = error.localizedDescription
            }
            isGenerating = false
        }
    }
}
