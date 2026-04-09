import SwiftUI
import FoundationModels

struct TextGenerationView: View {
    @State private var instructions = "你是一个有帮助的AI助手，请用中文回答。"
    @State private var prompt = ""
    @State private var responseText = ""
    @State private var isGenerating = false
    @State private var duration: TimeInterval?
    @State private var error: String?

    var body: some View {
        Form {
            Section("系统指令 (Instructions)") {
                TextField("系统指令...", text: $instructions, axis: .vertical)
                    .lineLimit(2...5)
                Text("通过 Instructions 设置模型的角色和行为")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("输入") {
                TextField("输入你的问题...", text: $prompt, axis: .vertical)
                    .lineLimit(2...8)

                Button("生成") {
                    generate()
                }
                .disabled(prompt.isEmpty || isGenerating)
            }

            Section("响应") {
                if isGenerating {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("生成中...")
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
                    LabeledContent("耗时") {
                        Text(String(format: "%.2f 秒", duration))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("API 说明") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("let session = LanguageModelSession(instructions: ...)")
                    Text("let response = try await session.respond(to: prompt)")
                    Text("response.content  // String")
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
                let response = try await session.respond(to: prompt)
                duration = CFAbsoluteTimeGetCurrent() - start
                responseText = response.content
            } catch {
                self.error = error.localizedDescription
            }
            isGenerating = false
        }
    }
}
