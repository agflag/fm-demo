import SwiftUI
import FoundationModels

struct GuidedGenerationView: View {
    @State private var input = "推荐一家适合约会的餐厅"
    @State private var result: RestaurantRecommendation?
    @State private var isGenerating = false
    @State private var error: String?

    var body: some View {
        Form {
            Section("@Guide 约束说明") {
                Text("RestaurantRecommendation 模型使用了多种 @Guide 约束来控制生成结果：")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    guideRow("cuisine", ".anyOf([\"中餐\",\"日料\",\"西餐\"...])")
                    guideRow("priceLevel", ".range(1...5)")
                    guideRow("rating", ".range(1...10)")
                    guideRow("mustTryDishes", ".count(3)")
                    guideRow("name", "无约束 (自由生成)")
                    guideRow("description", "无约束 (自由生成)")
                }
                .font(.system(.caption, design: .monospaced))
            }

            Section("输入") {
                TextField("描述你的需求...", text: $input, axis: .vertical)
                    .lineLimit(2...5)

                Button("生成推荐") {
                    generate()
                }
                .disabled(input.isEmpty || isGenerating)
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

            if let recommendation = result {
                Section("推荐结果") {
                    LabeledContent("餐厅") {
                        Text(recommendation.name).bold()
                    }
                    LabeledContent("菜系") {
                        Text(recommendation.cuisine)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    LabeledContent("价格等级") {
                        let clamped = min(max(recommendation.priceLevel, 0), 5)
                        HStack(spacing: 2) {
                            ForEach(0..<clamped, id: \.self) { _ in
                                Text("$").bold().foregroundStyle(.green)
                            }
                            ForEach(0..<(5 - clamped), id: \.self) { _ in
                                Text("$").foregroundStyle(.gray.opacity(0.3))
                            }
                        }
                        .accessibilityLabel("价格等级 \(clamped)，满分 5")
                    }
                    LabeledContent("评分") {
                        Text("\(recommendation.rating)/10")
                            .font(.title3.bold())
                            .foregroundStyle(.orange)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("描述").font(.subheadline).foregroundStyle(.secondary)
                        Text(recommendation.description)
                    }
                }

                Section("必点菜品 (count: 3)") {
                    ForEach(recommendation.mustTryDishes, id: \.self) { dish in
                        Label(dish, systemImage: "fork.knife")
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    @ViewBuilder
    private func guideRow(_ field: String, _ constraint: String) -> some View {
        HStack(spacing: 4) {
            Text(field)
                .foregroundStyle(.blue)
            Text("->")
                .foregroundStyle(.secondary)
            Text(constraint)
                .foregroundStyle(.orange)
        }
    }

    private func generate() {
        isGenerating = true
        result = nil
        error = nil

        Task {
            do {
                let session = LanguageModelSession(
                    instructions: Instructions("你是一个美食推荐专家。根据用户需求推荐餐厅。")
                )
                let response = try await session.respond(
                    to: input,
                    generating: RestaurantRecommendation.self
                )
                result = response.content
            } catch {
                self.error = error.localizedDescription
            }
            isGenerating = false
        }
    }
}
