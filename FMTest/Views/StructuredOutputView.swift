import SwiftUI
import FoundationModels

struct StructuredOutputView: View {
    enum OutputType: String, CaseIterable, Identifiable {
        case movieReview = "电影评论分析"
        case contactInfo = "联系人信息提取"

        var id: String { rawValue }

        var exampleInput: String {
            switch self {
            case .movieReview:
                "这部电影太棒了！《星际穿越》让我深深感动，诺兰把科幻和亲情完美结合。视觉效果震撼，配乐感人，强烈推荐！唯一的缺点是有些地方节奏稍慢。"
            case .contactInfo:
                "你好，我是张明，在腾讯做产品经理。我的邮箱是zhangming@example.com，手机号是13800138000，有什么需要随时联系我。"
            }
        }
    }

    @State private var selectedType: OutputType = .movieReview
    @State private var input = ""
    @State private var movieResult: MovieReview?
    @State private var contactResult: ContactInfo?
    @State private var isGenerating = false
    @State private var error: String?

    var body: some View {
        Form {
            Section("输出类型") {
                Picker("类型", selection: $selectedType) {
                    ForEach(OutputType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedType) {
                    input = selectedType.exampleInput
                    movieResult = nil
                    contactResult = nil
                    error = nil
                }
            }

            Section("输入文本") {
                TextField("输入要分析的文本...", text: $input, axis: .vertical)
                    .lineLimit(3...8)

                Button("提取结构化数据") {
                    generate()
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

            if let movie = movieResult {
                Section("电影评论分析结果") {
                    LabeledContent("标题", value: movie.title)
                    LabeledContent("评分") {
                        let clamped = min(max(movie.rating, 0), 5)
                        HStack(spacing: 2) {
                            ForEach(0..<clamped, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                            }
                            ForEach(0..<(5 - clamped), id: \.self) { _ in
                                Image(systemName: "star")
                                    .foregroundStyle(.gray.opacity(0.3))
                            }
                        }
                        .accessibilityLabel("\(clamped) 星，满分 5 星")
                    }
                    LabeledContent("情感倾向", value: movie.sentiment)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("主题").font(.subheadline).foregroundStyle(.secondary)
                        FlowLayout(spacing: 6) {
                            ForEach(movie.themes, id: \.self) { theme in
                                Text(theme)
                                    .font(.callout)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("摘要").font(.subheadline).foregroundStyle(.secondary)
                        Text(movie.summary)
                    }
                }
            }

            if let contact = contactResult {
                Section("联系人信息") {
                    LabeledContent("姓名", value: contact.name)
                    if let email = contact.email {
                        LabeledContent("邮箱", value: email)
                    }
                    if let phone = contact.phone {
                        LabeledContent("电话", value: phone)
                    }
                    if let company = contact.company {
                        LabeledContent("公司", value: company)
                    }
                    if let role = contact.role {
                        LabeledContent("职位", value: role)
                    }
                }
            }

            Section("API 说明") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("@Generable struct MovieReview { ... }")
                    Text("let response = try await session.respond(")
                    Text("    to: input,")
                    Text("    generating: MovieReview.self")
                    Text(")")
                    Text("let movie = response.content  // MovieReview")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            input = selectedType.exampleInput
        }
    }

    private func generate() {
        isGenerating = true
        movieResult = nil
        contactResult = nil
        error = nil

        Task {
            do {
                let session = LanguageModelSession()
                switch selectedType {
                case .movieReview:
                    let response = try await session.respond(
                        to: input,
                        generating: MovieReview.self
                    )
                    movieResult = response.content
                case .contactInfo:
                    let response = try await session.respond(
                        to: input,
                        generating: ContactInfo.self
                    )
                    contactResult = response.content
                }
            } catch {
                self.error = error.localizedDescription
            }
            isGenerating = false
        }
    }
}
