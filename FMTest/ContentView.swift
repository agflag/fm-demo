import SwiftUI

enum DemoItem: String, CaseIterable, Identifiable, Hashable {
    case availability
    case textGeneration
    case streaming
    case structuredOutput
    case guidedGeneration
    case toolCalling
    case multiTurnChat
    case promptBuilder
    case performance
    case contentTagging

    var id: String { rawValue }

    var title: String {
        switch self {
        case .availability: "可用性检查"
        case .textGeneration: "文本生成"
        case .streaming: "流式输出"
        case .structuredOutput: "结构化输出"
        case .guidedGeneration: "引导生成"
        case .toolCalling: "工具调用"
        case .multiTurnChat: "多轮对话"
        case .promptBuilder: "Prompt Builder"
        case .performance: "性能测试"
        case .contentTagging: "内容标注"
        }
    }

    var icon: String {
        switch self {
        case .availability: "checkmark.circle"
        case .textGeneration: "text.bubble"
        case .streaming: "text.word.spacing"
        case .structuredOutput: "doc.text.magnifyingglass"
        case .guidedGeneration: "slider.horizontal.3"
        case .toolCalling: "wrench.and.screwdriver"
        case .multiTurnChat: "bubble.left.and.bubble.right"
        case .promptBuilder: "hammer"
        case .performance: "gauge.with.dots.needle.67percent"
        case .contentTagging: "tag"
        }
    }

    var subtitle: String {
        switch self {
        case .availability: "SystemLanguageModel 状态与设备能力"
        case .textGeneration: "session.respond(to:) 基础文本生成"
        case .streaming: "session.streamResponse(to:) 流式输出"
        case .structuredOutput: "@Generable 结构化数据提取"
        case .guidedGeneration: "@Guide 约束条件控制生成"
        case .toolCalling: "Tool 协议实现工具调用"
        case .multiTurnChat: "Session 多轮上下文对话 + Transcript"
        case .promptBuilder: "@PromptBuilder 动态提示词组合"
        case .performance: "Prewarm / Sampling / Temperature"
        case .contentTagging: "UseCase.contentTagging 内容标签"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .availability: AvailabilityView()
        case .textGeneration: TextGenerationView()
        case .streaming: StreamingView()
        case .structuredOutput: StructuredOutputView()
        case .guidedGeneration: GuidedGenerationView()
        case .toolCalling: ToolCallingView()
        case .multiTurnChat: MultiTurnChatView()
        case .promptBuilder: PromptBuilderView()
        case .performance: PerformanceView()
        case .contentTagging: ContentTaggingView()
        }
    }
}

struct ContentView: View {
    @State private var selectedDemo: DemoItem?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedDemo) {
                ForEach(DemoItem.allCases) { demo in
                    VStack(alignment: .leading, spacing: 4) {
                        Label(demo.title, systemImage: demo.icon)
                            .font(.headline)
                        Text(demo.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .tag(demo)
                }
            }
            .navigationTitle("FM Demo")
        } detail: {
            if let demo = selectedDemo {
                demo.destination
                    .navigationTitle(demo.title)
            } else {
                ContentUnavailableView(
                    "Foundation Models",
                    systemImage: "brain",
                    description: Text("从左侧选择一个功能演示")
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
