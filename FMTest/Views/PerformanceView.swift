import SwiftUI
import FoundationModels

struct PerformanceView: View {
    @State private var testPrompt = "用三句话解释什么是机器学习。"
    @State private var results: [TestResult] = []
    @State private var isRunning = false

    struct TestResult: Identifiable {
        let id = UUID()
        let name: String
        let duration: Duration
        let response: String

        var durationText: String {
            let total = Double(duration.components.seconds)
                + Double(duration.components.attoseconds) * 1e-18
            return String(format: "%.2fs", total)
        }
    }

    var body: some View {
        Form {
            Section("测试提示词") {
                TextField("", text: $testPrompt, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("测试项目") {
                Button("1. 预热 (Prewarm) 对比") {
                    runPrewarmTest()
                }

                Button("2. 采样模式对比") {
                    runSamplingTest()
                }

                Button("3. 温度参数对比") {
                    runTemperatureTest()
                }

                Button("清除结果", role: .destructive) {
                    results = []
                }
            }
            .disabled(isRunning)

            if isRunning {
                Section {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("测试运行中...")
                    }
                }
            }

            if !results.isEmpty {
                Section("测试结果") {
                    ForEach(results) { result in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(result.name)
                                    .font(.subheadline.bold())
                                Spacer()
                                Text(result.durationText)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.blue)
                            }
                            Text(result.response)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(4)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("API 说明") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("// 预热")
                    Text("await session.prewarm()")
                    Text("")
                    Text("// 采样选项")
                    Text("GenerationOptions(sampling: .greedy)")
                    Text("GenerationOptions(sampling: .random(probabilityThreshold: 0.9))")
                    Text("GenerationOptions(temperature: 0.5)")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private let clock = ContinuousClock()

    private func measure(_ work: () async throws -> String) async -> (Duration, String) {
        do {
            var result = ""
            let elapsed = try await clock.measure {
                result = try await work()
            }
            return (elapsed, result)
        } catch {
            return (.zero, "Error: \(error.localizedDescription)")
        }
    }

    private func runPrewarmTest() {
        isRunning = true
        results = []

        Task {
            // Cold: 不预热直接生成
            let (coldDuration, coldResponse) = await measure {
                let session = LanguageModelSession()
                return try await session.respond(to: testPrompt).content
            }
            results.append(TestResult(name: "Cold (无预热)", duration: coldDuration, response: coldResponse))

            // Warm: 先预热再生成
            let (warmDuration, warmResponse) = await measure {
                let session = LanguageModelSession()
                await session.prewarm()
                return try await session.respond(to: testPrompt).content
            }
            results.append(TestResult(name: "Warm (已预热)", duration: warmDuration, response: warmResponse))

            isRunning = false
        }
    }

    private func runSamplingTest() {
        isRunning = true
        results = []

        Task {
            let modes: [(String, GenerationOptions)] = [
                ("Greedy (贪心)", GenerationOptions(sampling: .greedy)),
                ("Random p=0.9 (核采样)", GenerationOptions(sampling: .random(probabilityThreshold: 0.9))),
                ("Top-K k=40", GenerationOptions(sampling: .random(top: 40))),
            ]

            for (name, options) in modes {
                let (elapsed, response) = await measure {
                    let session = LanguageModelSession()
                    return try await session.respond(to: testPrompt, options: options).content
                }
                results.append(TestResult(name: name, duration: elapsed, response: response))
            }

            isRunning = false
        }
    }

    private func runTemperatureTest() {
        isRunning = true
        results = []

        Task {
            for temp in [0.0, 0.5, 1.0, 1.5] {
                let label = String(format: "Temperature %.1f", temp)
                let (elapsed, response) = await measure {
                    let session = LanguageModelSession()
                    let options = GenerationOptions(temperature: temp)
                    return try await session.respond(to: testPrompt, options: options).content
                }
                results.append(TestResult(name: label, duration: elapsed, response: response))
            }

            isRunning = false
        }
    }
}
