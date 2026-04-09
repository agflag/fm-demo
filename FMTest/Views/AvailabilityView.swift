import SwiftUI
import FoundationModels

struct AvailabilityView: View {
    @State private var tokenInput = ""
    @State private var tokenCount: Int?

    private let model = SystemLanguageModel.default

    var body: some View {
        Form {
            Section("模型状态") {
                LabeledContent("可用性") {
                    switch model.availability {
                    case .available:
                        Label("可用", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    case .unavailable(let reason):
                        Label(reasonText(reason), systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    @unknown default:
                        Label("未知", systemImage: "questionmark.circle")
                    }
                }

                LabeledContent("模型可用") {
                    Image(systemName: model.isAvailable ? "checkmark" : "xmark")
                        .foregroundStyle(model.isAvailable ? .green : .red)
                }
            }

            if model.isAvailable {
                Section("模型信息") {
                    LabeledContent("上下文窗口") {
                        Text("\(model.contextSize) tokens")
                            .font(.system(.body, design: .monospaced))
                    }

                    LabeledContent("支持的语言") {
                        let langs = model.supportedLanguages
                            .compactMap { $0.languageCode?.identifier }
                            .sorted()
                        Text(langs.joined(separator: ", "))
                    }
                }
            }

            Section("Token 计数器") {
                TextField("输入文本来计算 token 数...", text: $tokenInput, axis: .vertical)
                    .lineLimit(3...8)

                Button("计算 Token 数量") {
                    Task {
                        if model.isAvailable {
                            tokenCount = try? await model.tokenCount(for: Prompt(tokenInput))
                        }
                    }
                }
                .disabled(tokenInput.isEmpty || !model.isAvailable)

                if let count = tokenCount {
                    LabeledContent("Token 数量") {
                        Text("\(count)")
                            .font(.title2.bold())
                            .foregroundStyle(.blue)
                    }
                }
            }

            Section("API 说明") {
                VStack(alignment: .leading, spacing: 8) {
                    codeRow("SystemLanguageModel.default", "获取默认模型")
                    codeRow(".availability", "检查可用性状态")
                    codeRow(".contextSize", "上下文窗口大小")
                    codeRow(".supportedLanguages", "支持的语言列表")
                    codeRow(".tokenCount(for:)", "计算文本 token 数")
                }
                .font(.system(.caption, design: .monospaced))
            }
        }
        .formStyle(.grouped)
    }

    private func reasonText(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible: "设备不支持 Apple Intelligence"
        case .appleIntelligenceNotEnabled: "Apple Intelligence 未启用"
        case .modelNotReady: "模型正在下载或准备中"
        @unknown default: "未知原因"
        }
    }

    @ViewBuilder
    private func codeRow(_ api: String, _ desc: String) -> some View {
        HStack {
            Text(api)
                .foregroundStyle(.blue)
            Spacer()
            Text(desc)
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}
