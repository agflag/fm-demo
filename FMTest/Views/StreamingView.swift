import SwiftUI
import FoundationModels

struct StreamingView: View {
    @State private var instructions = "你是一个有帮助的AI助手。请详细回答问题。"
    @State private var prompt = ""
    @State private var responseText = ""
    @State private var isGenerating = false
    @State private var useStreaming = true
    @State private var duration: TimeInterval?
    @State private var error: String?

    var body: some View {
        Form {
            Section("设置") {
                TextField("系统指令...", text: $instructions, axis: .vertical)
                    .lineLimit(2...4)
                Toggle("流式输出", isOn: $useStreaming)
            }

            Section("输入") {
                TextField("输入你的问题...", text: $prompt, axis: .vertical)
                    .lineLimit(2...6)

                Button(useStreaming ? "流式生成" : "普通生成") {
                    generate()
                }
                .disabled(prompt.isEmpty || isGenerating)
            }

            Section("响应") {
                if isGenerating {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(useStreaming ? "流式生成中..." : "生成中...")
                            .foregroundStyle(.secondary)
                    }
                }

                if let error {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }

                if !responseText.isEmpty {
                    Text(responseText)
                        .textSelection(.enabled)
                }

                if let duration {
                    LabeledContent("总耗时") {
                        Text(String(format: "%.2f 秒", duration))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("API 说明") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("// 流式")
                    Text("let stream = session.streamResponse(to: prompt)")
                    Text("for try await partial in stream { ... }")
                    Text("")
                    Text("// 非流式")
                    Text("let response = try await session.respond(to: prompt)")
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
        error = nil
        duration = nil

        Task {
            do {
                let session = LanguageModelSession(
                    instructions: Instructions(instructions)
                )
                let start = CFAbsoluteTimeGetCurrent()

                if useStreaming {
                    let stream = session.streamResponse(to: prompt)
                    for try await partial in stream {
                        responseText = partial.content
                    }
                } else {
                    let response = try await session.respond(to: prompt)
                    responseText = response.content
                }

                duration = CFAbsoluteTimeGetCurrent() - start
            } catch {
                self.error = error.localizedDescription
            }
            isGenerating = false
        }
    }
}
