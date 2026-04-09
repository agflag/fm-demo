import SwiftUI
import FoundationModels

private struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp = Date()

    enum Role {
        case user, assistant, system
    }
}

struct MultiTurnChatView: View {
    @State private var session: LanguageModelSession?
    @State private var messages: [ChatMessage] = []
    @State private var input = ""
    @State private var isGenerating = false
    @State private var showTranscript = false

    var body: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            chatBubble(message)
                                .id(message.id)
                        }

                        if isGenerating {
                            HStack {
                                ProgressView()
                                    .padding(12)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input bar
            HStack(spacing: 12) {
                TextField("输入消息...", text: $input, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.roundedBorder)

                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(input.isEmpty || isGenerating)
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showTranscript = true
                } label: {
                    Image(systemName: "doc.text")
                }

                Button("重置", role: .destructive) {
                    reset()
                }
            }
        }
        .sheet(isPresented: $showTranscript) {
            transcriptSheet
        }
        .onAppear {
            if session == nil {
                startSession()
            }
        }
    }

    @ViewBuilder
    private func chatBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 60) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(bubbleColor(message.role))
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if message.role != .user { Spacer(minLength: 60) }
        }
    }

    private func bubbleColor(_ role: ChatMessage.Role) -> Color {
        switch role {
        case .user: .blue
        case .assistant: Color(.systemGray5)
        case .system: Color(.systemGray6)
        }
    }

    private var transcriptSheet: some View {
        NavigationStack {
            ScrollView {
                if let session {
                    Text(String(describing: session.transcript))
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .textSelection(.enabled)
                } else {
                    ContentUnavailableView("暂无 Transcript", systemImage: "doc.text")
                }
            }
            .navigationTitle("Transcript")
            .toolbar {
                Button("关闭") { showTranscript = false }
            }
        }
    }

    private func startSession() {
        session = LanguageModelSession(
            instructions: Instructions("你是一个有帮助的AI助手。请记住对话上下文，用中文回答。回答要简洁有用。")
        )
        messages.append(ChatMessage(
            role: .system,
            content: "多轮对话已开始。同一个 Session 会自动维护上下文。"
        ))
    }

    private func send() {
        let text = input
        input = ""
        messages.append(ChatMessage(role: .user, content: text))
        isGenerating = true

        Task {
            do {
                guard let session else { return }
                let response = try await session.respond(to: text)
                messages.append(ChatMessage(role: .assistant, content: response.content))
            } catch {
                messages.append(ChatMessage(role: .system, content: "Error: \(error.localizedDescription)"))
            }
            isGenerating = false
        }
    }

    private func reset() {
        session = nil
        messages = []
        startSession()
    }
}
